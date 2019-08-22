defprotocol Percussion.Declarative.Dispatcher do
  @moduledoc """
  Dispatcher protocol used by `Percussion.Router`.

  Describes composable modules that are meant to operate on `t:Percussion.Request.t/0`.
  """

  alias Percussion.Request

  @doc """
  Returns the list of names that `entry` should match on.
  """
  @spec aliases(term) :: [String.t()]
  def aliases(entry)

  @doc """
  Returns the help for every command under this dispatcher.
  """
  @spec describe(term) :: %{String.t() => Command.t()}
  def describe(entry)

  @doc """
  Executes the command that matches on `t:Percussion.Request.t/0`.
  """
  @spec execute(term, Request.t()) :: {:ok, Request.t()} | :error
  def execute(entry, request)
end
