defmodule Percussion.Request do
  @moduledoc """
  A bot command request.
  """

  alias Percussion.Request

  @typedoc "Callbacks to be called right after the response is sent."
  @type after_send :: [step]

  @typedoc "The arguments that were passed to the command."
  @type arguments :: [String.t()]

  @typedoc "Data shared between steps."
  @type assigns :: %{atom => any}

  @typedoc "The user which triggered this request."
  @type author_id :: term

  @typedoc "The channel in which this request was made."
  @type channel_id :: term

  @typedoc "The guild in which this request was made."
  @type guild_id :: term

  @typedoc "Whether to stop propagating this request."
  @type halt :: boolean

  @typedoc "A value that can converted into a `t:Request.t/0`."
  @type into :: t | String.t()

  @typedoc "The command name that triggered this request."
  @type invoked_with :: String.t()

  @typedoc "Reference to the message which triggered this request."
  @type message :: term | nil

  @typedoc "The message which triggered this request."
  @type message_id :: term

  @typedoc "A single step in the pipeline."
  @type step :: (t -> into)

  @type t :: %Request{
          after_send: after_send,
          arguments: arguments,
          assigns: assigns,
          author_id: author_id,
          channel_id: channel_id,
          guild_id: guild_id,
          halt: halt,
          invoked_with: invoked_with,
          message: message,
          message_id: message_id
        }

  @enforce_keys [:invoked_with]

  defstruct [
    :author_id,
    :channel_id,
    :guild_id,
    :invoked_with,
    :message,
    :message_id,
    after_send: [],
    arguments: [],
    assigns: %{},
    halt: false
  ]

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
    assign(request, content: response)
  end

  @doc """
  Halts the pipeline, preventing downstream steps from being executed.
  """
  @spec halt(t) :: t
  def halt(%Request{} = request) do
    %Request{request | halt: true}
  end

  @doc """
  Halts the pipeline with the given response, preventing downstream steps from being
  executed.

  Equivalent to calling `halt/1` and `reply/2`.
  """
  @spec halt(t, String.t()) :: t
  def halt(%Request{} = request, response) do
    request
    |> reply(response)
    |> halt()
  end

  @doc """
  Resumes an halted pipeline.
  """
  @spec resume(t) :: t
  def resume(%Request{} = request) do
    %Request{request | halt: false}
  end

  @doc """
  Maps `request` by applying `fun` on it.

  If the value returned by `fun` is a string, the request is halted with the returned
  string as a response.
  """
  @spec map(t, step) :: t
  def map(%Request{} = request, fun) do
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
  Maps `request` by applying a function if it's halted, otherwise leave it
  untouched.
  """
  @spec or_else(t, step) :: t
  def or_else(request, fun)

  def or_else(%Request{halt: true} = request, fun), do: map(request, fun)

  def or_else(%Request{halt: false} = request, _fun), do: request

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
  Executes the callbacks registered to be called after the request was sent.
  """
  @spec execute_after_send(t) :: t
  def execute_after_send(%Request{} = request) do
    Enum.reduce(request.after_send, request, &map(&2, &1))
  end
end
