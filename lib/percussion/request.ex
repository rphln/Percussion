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

  @typedoc "A single step in the pipeline."
  @type step :: (t -> t)

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
  def assign(request, assigns) do
    update_in(request.assigns, &Enum.into(assigns, &1))
  end

  @doc """
  Halts the pipeline, preventing downstream pipes from being executed.
  """
  @spec halt(t) :: t
  def halt(request) do
    %Request{request | halt: true}
  end

  @doc """
  Halts the pipeline with the given response, preventing downstream pipes from
  being executed.

  Equivalent to calling `halt/1` and `reply/2`.
  """
  @spec halt(t, String.t()) :: t
  def halt(request, response) do
    request |> reply(response) |> halt()
  end

  @doc """
  Maps `request` by applying a function if it's not halted, otherwise leave it
  untouched.
  """
  @spec map(t, step) :: t
  def map(request, fun)

  def map(%{halt: false} = request, fun), do: fun.(request)

  def map(%{halt: true} = request, _fun), do: request

  @doc """
  Maps `request` with each element in `pipeline` in order.

  See `map/2`. This function terminates when `pipeline` is exhausted, or if any of its
  elements halts the request.
  """
  @spec pipe(t, [step]) :: t
  def pipe(request, pipeline) do
    Enum.reduce_while(pipeline, request, &apply_step/2)
  end

  @doc """
  Registers a callback to be invoked after the response is sent.

  Callbacks are invoked regardless of the request being halted, and are executed in
  first-in, last-out order.
  """
  @spec register_after_send(t, step) :: t
  def register_after_send(request, callback) do
    update_in(request.after_send, &[callback | &1])
  end

  @doc """
  Sets the response for the request.
  """
  @spec reply(t, String.t()) :: t
  def reply(request, response) do
    %Request{request | response: response}
  end

  @doc """
  Sends a response to the client using `callback`.
  """
  @spec send_response(t, step) :: t
  def send_response(request, callback) do
    request |> callback.() |> reduce(request.after_send)
  end

  ## Helpers.

  defp apply_step(fun, request) do
    case response = Request.map(request, fun) do
      %Request{halt: false} ->
        {:cont, response}

      %Request{halt: true} ->
        {:halt, response}

      _ ->
        raise ArgumentError,
          message: "Expected `#{inspect(fun)}` to return a `Percussion.Request`."
    end
  end

  defp reduce(request, pipeline) do
    Enum.reduce(pipeline, request, fn callback, response ->
      callback.(response)
    end)
  end
end
