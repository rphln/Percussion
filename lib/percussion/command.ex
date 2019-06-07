defmodule Percussion.Command do
  @moduledoc """
  A command specification.
  """

  alias Percussion.Command
  alias Percussion.Dispatcher
  alias Percussion.Request

  @typedoc "List of names that this dispatcher will match on."
  @type aliases :: [String.t()]

  @typedoc "Function which will be called by this command."
  @type dispatch :: Request.transform()

  @typedoc "Description for this command."
  @type description :: String.t()

  @typedoc "Transformations to apply before executing."
  @type pipeline :: [Request.transform()]

  @type t :: %Command{
          aliases: aliases,
          description: description,
          dispatch: dispatch,
          pipeline: pipeline
        }

  @enforce_keys [:aliases, :dispatch]

  defstruct aliases: [],
            dispatch: nil,
            description: nil,
            pipeline: []

  @doc """
  Returns the specification for the given command.
  """
  @spec spec(String.t(), dispatch, Keyword.t()) :: t
  def spec(name, dispatch, opts \\ []) do
    aliases = opts[:aliases] || []
    pipeline = opts[:pipe] || []

    %Command{
      aliases: [name | aliases],
      dispatch: dispatch,
      description: opts[:description],
      pipeline: pipeline
    }
  end

  defimpl Dispatcher do
    def aliases(command) do
      command.aliases
    end

    def execute(command, request) do
      response =
        request
        |> Request.pipe(command.pipeline)
        |> Request.map(command.dispatch)

      {:ok, response}
    end

    def describe(command, _name) do
      {:ok, command.description}
    end
  end
end
