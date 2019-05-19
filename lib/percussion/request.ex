defmodule Percussion.Request do
  @moduledoc """
  A bot command request.
  """

  alias Percussion.Request

  alias Nostrum.Struct.Message

  @typedoc "The list of arguments that were passed into the command."
  @type arguments :: [String.t()]

  @typedoc "Shared data."
  @type assigns :: %{atom => any}

  @typedoc "Whether to stop propagating this request."
  @type halt :: boolean

  @typedoc "The command name that triggered this request."
  @type invoked_with :: String.t()

  @typedoc "The message which triggered this request."
  @type message :: Message.t()

  @typedoc "The response to send to the user."
  @type response :: String.t() | nil

  @type t :: %Request{
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
    request
    |> reply(response)
    |> halt()
  end

  @doc """
  Maps a `request` by applying a function if it's not halted, otherwise leave it
  untouched.
  """
  @spec map(t, (t -> t)) :: t
  def map(request, fun)

  def map(%Request{halt: false} = request, fun), do: fun.(request)

  def map(%Request{halt: true} = request, _fun), do: request

  @doc """
  Sets the response for the request.
  """
  @spec reply(t, String.t()) :: t
  def reply(%Request{} = request, response) do
    %Request{request | response: response}
  end
end
