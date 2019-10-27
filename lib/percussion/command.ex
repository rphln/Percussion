defmodule Percussion.Command do
  @moduledoc """
  Specification for command modules.
  """

  alias Percussion.Request

  @type t :: module

  @doc """
  Returns the list of names that this command should match on.

  The first element in the list is treated as the command's primary name.
  """
  @callback aliases :: [String.t()]

  @doc """
  Executes the command on the request.
  """
  @callback call(request :: Request.t()) :: Request.t()

  @doc """
  Returns the help message for this command.
  """
  @callback help :: String.t()

  @doc """
  Returns a short description for this command.
  """
  @callback describe :: String.t()

  @doc """
  Returns the usage messages for this command.
  """
  @callback usage :: [String.t()]

  @optional_callbacks help: 0, usage: 0, describe: 0

  @doc """
  Returns whether the specified `command` has a description.
  """
  @spec has_description?(t) :: boolean
  def has_description?(command) do
    function_exported?(command, :describe, 0)
  end

  @doc """
  Returns the description for the specified `command`.
  """
  @spec describe(t) :: String.t() | nil
  def describe(command) do
    if has_description?(command) do
      apply(command, :describe, [])
    end
  end

  @doc """
  Returns the primary name for the specified `command`.
  """
  @spec name(t) :: String.t()
  def name(command) do
    [name | _rest] = apply(command, :aliases, [])
    name
  end
end
