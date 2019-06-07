defprotocol Percussion.Dispatcher do
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
  Returns the description for the command that matches on `name`.
  """
  @spec describe(term, String.t()) :: {:ok, String.t() | nil} | :error
  def describe(entry, name)

  @doc """
  Executes the command that matches on `t:Percussion.Request.t/0`.
  """
  @spec execute(term, Request.t()) :: {:ok, Request.t()} | :error
  def execute(entry, request)

  defdelegate command(name, dispatch, opts \\ []), to: Percussion.Command, as: :spec

  defdelegate router(entries, opts \\ []), to: Percussion.Router, as: :compile
end
