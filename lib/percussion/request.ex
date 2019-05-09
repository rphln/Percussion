defmodule Percussion.Request do
  @moduledoc """
  A bot command request.
  """

  alias Nostrum.Struct.Message
  alias Percussion.Request

  defstruct arguments: [],
            assigns: %{},
            halt: false,
            invoked_with: nil,
            message: nil

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

  @type t :: %Request{
          arguments: arguments,
          assigns: assigns,
          halt: halt,
          invoked_with: invoked_with,
          message: message
        }

  @doc """
  Assigns multiple values to the request.
  """
  def assign(%Request{assigns: assigns} = request, keyword) do
    %Request{request | assigns: Enum.into(keyword, assigns)}
  end

  @doc """
  Halts the pipeline, preventing downstream pipes from being executed.
  """
  def halt(%Request{} = request) do
    %Request{request | halt: true}
  end

  @doc """
  Halts the pipeline with the given response, preventing downstream pipes from
  being executed.

  Equivalent to calling `halt/1` and assigning `response` with `assign/2`.
  """
  def halt(%Request{} = request, response) do
    request
    |> reply(response)
    |> halt()
  end

  @doc """
  Sets the response for the request.

  Equivalent to assigning `response` with `assign/2`.
  """
  def reply(%Request{} = request, response) do
    request
    |> assign(response: response)
  end
end
