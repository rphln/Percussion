defmodule Percussion.Request do
  @moduledoc """
  A bot command request.
  """

  alias __MODULE__

  @typedoc "The list of arguments that were passed into the command."
  @type arguments :: [String.t()]

  @typedoc "Additional data shared between steps."
  @type assigns :: %{atom => any}

  @typedoc "Callbacks to be called right before the response is sent."
  @type before_send :: [step]

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
          arguments: arguments,
          assigns: assigns,
          before_send: before_send,
          halt: halt,
          invoked_with: invoked_with,
          message: message,
          response: response
        }

  @enforce_keys [:invoked_with]

  defstruct arguments: [],
            assigns: %{},
            before_send: [],
            halt: false,
            invoked_with: nil,
            message: nil,
            response: nil

  @doc """
  Assigns multiple values to the request.
  """
  @spec assign(t, Keyword.t()) :: t
  def assign(%Request{assigns: assigns} = request, keyword) when is_list(keyword) do
    %Request{request | assigns: Enum.into(keyword, assigns)}
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
    request |> reply(response) |> halt()
  end

  @doc """
  Maps `request` by applying a function if it's not halted, otherwise leave it
  untouched.
  """
  @spec map(t, step) :: t
  def map(request, fun)

  def map(%Request{halt: false} = request, fun), do: fun.(request)

  def map(%Request{halt: true} = request, _fun), do: request

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
  Registers a callback to be invoked before the response is sent.

  Callbacks are invoked regardless of the request being halted, and are executed in
  first-in, last-out order.
  """
  @spec register_before_send(t, step) :: t
  def register_before_send(%Request{before_send: before_send} = request, callback) do
    %Request{request | before_send: [callback | before_send]}
  end

  @doc """
  Sets the response for the request.
  """
  @spec reply(t, String.t()) :: t
  def reply(%Request{} = request, response) do
    %Request{request | response: response}
  end

  @doc """
  Sends a response to the client using `callback`.
  """
  @spec send_response(t, step) :: t
  def send_response(%Request{} = request, callback) do
    request |> before_send() |> callback.()
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

  defp before_send(request) do
    Enum.reduce(request.before_send, request, fn callback, response ->
      callback.(response)
    end)
  end
end
