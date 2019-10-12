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
  Returns the usage messages for this command.
  """
  @callback usage :: [String.t()]
end
