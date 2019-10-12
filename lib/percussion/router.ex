defmodule Percussion.Router do
  @moduledoc """
  Command routing specification.
  """

  alias Percussion.Request

  @typedoc "Routing table."
  @type routes :: %{String.t() => Command.t()}

  @doc """
  Builds a routing table for the given `modules`.
  """
  @spec new([Command.t()]) :: routes
  def new(modules) do
    Enum.reduce(modules, %{}, &put(&2, &1))
  end

  @doc """
  Inserts `route` into the routing table.
  """
  @spec put(routes, Command.t()) :: routes
  def put(routes, route) do
    for name <- apply(route, :aliases, []), into: routes, do: {name, route}
  end

  @doc """
  Executes the command that matches on `request`.
  """
  @spec dispatch(routes, Request.t()) :: Request.t()
  def dispatch(routes, request) do
    resolve_and_apply(routes, request.invoked_with, :call, [request])
  end

  @doc """
  Returns the help message for the command that matches on `name`.
  """
  @spec help(routes, String.t()) :: {:ok, String.t()} | :error
  def help(routes, name) do
    resolve_and_apply(routes, name, :help)
  end

  @doc """
  Returns the usage messages for the command that matches on `name`.
  """
  @spec usage(routes, String.t()) :: {:ok, [String.t()]} | :error
  def usage(routes, name) do
    resolve_and_apply(routes, name, :usage)
  end

  @doc """
  Performs a lookup by `name` on `router`.
  """
  @spec resolve(routes, String.t()) :: {:ok, Command.t()} | :error
  def resolve(routes, name) do
    Map.fetch(routes, name)
  end

  defp resolve_and_apply(routes, name, method, params \\ []) do
    case resolve(routes, name) do
      {:ok, route} ->
        {:ok, apply(route, method, params)}

      :error ->
        :error
    end
  end
end
