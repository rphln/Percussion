defmodule Percussion.Declarative.Command do
  @moduledoc """
  A command specification.
  """

  alias Percussion.Declarative.Command
  alias Percussion.Declarative.Dispatcher
  alias Percussion.Request

  @typedoc "Names that this command will match on."
  @type aliases :: [String.t()]

  @typedoc "Description for this command."
  @type description :: String.t()

  @typedoc "Function which will be called by this command."
  @type dispatch :: Request.step()

  @type t :: %Command{
          aliases: aliases,
          description: description,
          dispatch: dispatch
        }

  @enforce_keys [:aliases, :dispatch]

  defstruct aliases: [],
            dispatch: nil,
            description: nil

  @doc """
  Returns the specification for the given command.
  """
  @spec new(String.t(), dispatch, Keyword.t()) :: t
  def new(name, dispatch, opts \\ []) do
    aliases = opts[:aliases] || []

    %Command{
      aliases: [name | aliases],
      dispatch: dispatch,
      description: opts[:description]
    }
  end

  defimpl Dispatcher do
    def aliases(command) do
      command.aliases
    end

    def execute(command, request) do
      {:ok, Request.map(request, command.dispatch)}
    end

    def describe(command, _name) do
      {:ok, command.description}
    end
  end
end
