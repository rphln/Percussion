defmodule Percussion.Request do
  @moduledoc """
  A bot command request.
  """

  alias Percussion.Request

  @typedoc "Callbacks to be called right after the response is sent."
  @type after_send :: [step]

  @typedoc "The list of arguments that were passed into the command."
  @type arguments :: [String.t()]

  @typedoc "Additional data shared between steps."
  @type assigns :: %{atom => any}

  @typedoc "Whether to stop propagating this request."
  @type halt :: boolean

  @typedoc "The command name that triggered this request."
  @type invoked_with :: String.t()

  @typedoc "The message which triggered this request."
  @type message :: Nostrum.Struct.Message.t()

  @typedoc "The response to send to the user."
  @type response :: String.t() | nil

  @typedoc "A value able to be converted into a request or response."
  @type into :: t | String.t()

  @typedoc "A single step in the pipeline."
  @type step :: (t -> into)

  @type t :: %Request{
          after_send: after_send,
          arguments: arguments,
          assigns: assigns,
          halt: halt,
          invoked_with: invoked_with,
          message: message,
          response: response
        }

  @enforce_keys [:invoked_with]

  defstruct arguments: [],
            assigns: %{},
            after_send: [],
            halt: false,
            invoked_with: nil,
            message: nil,
            response: nil

  @doc """
  Assigns multiple values to the request.
  """
  @spec assign(t, Keyword.t()) :: t
  def assign(%Request{} = request, assigns) do
    update_in(request.assigns, &Enum.into(assigns, &1))
  end

  @doc """
  Sets the response for the request.
  """
  @spec reply(t, String.t()) :: t
  def reply(%Request{} = request, response) do
    %Request{request | response: response}
  end

  @doc """
  Halts the pipeline, preventing downstream pipes from being executed.
  """
  @spec halt(t) :: t
  def halt(%Request{} = request) do
    %Request{request | halt: true}
  end

  @doc """
  Halts the pipeline with the given response, preventing downstream pipes from
  being executed.

  Equivalent to calling `halt/1` and `reply/2`.
  """
  @spec halt(t, String.t()) :: t
  def halt(%Request{} = request, response) do
    request
    |> reply(response)
    |> halt()
  end

  @doc """
  Maps `request` by applying `fun` on it.

  If the value returned by `fun` is a string, the request is halted with the returned
  string as a response.
  """
  @spec map(t, step) :: t
  def map(request, fun) do
    case fun.(request) do
      response when is_bitstring(response) ->
        halt(request, response)

      response ->
        response
    end
  end

  @doc """
  Maps `request` by applying a function if it's not halted, otherwise leave it
  untouched.
  """
  @spec and_then(t, step) :: t
  def and_then(request, fun)

  def and_then(%Request{halt: true} = request, _fun), do: request

  def and_then(%Request{halt: false} = request, fun), do: map(request, fun)

  @doc """
  Maps `request` with each element in `pipeline` in order.

  See `and_then/2`. This function terminates when `pipeline` is exhausted, or if any of
  its elements halts the request.
  """
  @spec pipe(t, [step]) :: t
  def pipe(%Request{} = request, pipeline) do
    Enum.reduce(pipeline, request, &and_then(&2, &1))
  end

  @doc """
  Registers a callback to be invoked after the response is sent.

  Callbacks are invoked regardless of the request being halted, and are executed in
  first-in, last-out order.
  """
  @spec register_after_send(t, step) :: t
  def register_after_send(%Request{} = request, callback) do
    update_in(request.after_send, &[callback | &1])
  end

  @doc """
  Sends a response to the client using `callback`.
  """
  @spec send_response(t, step) :: t
  def send_response(%Request{} = request, callback) do
    request
    |> callback.()
    |> reduce(request.after_send)
  end

  defp reduce(request, pipeline) do
    Enum.reduce(pipeline, request, &map(&2, &1))
  end
end
