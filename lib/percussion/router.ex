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
  @spec dispatch(routes, Request.t()) :: {:ok, Request.t() | nil} | :error
  def dispatch(routes, request) do
    with {:ok, route} <- resolve(routes, request.invoked_with) do
      pipe =
        if function_exported?(route, :pipe, 0) do
          apply(route, :pipe, [])
        else
          []
        end

      response =
        request
        |> Request.pipe(pipe)
        |> Request.and_then(&apply(route, :call, [&1]))

      {:ok, response}
    end
  end

  @doc """
  Returns the help message for the command that matches on `name`.
  """
  @spec help(routes, String.t()) :: {:ok, String.t() | nil} | :error
  def help(routes, name) do
    resolve_and_apply(routes, name, {:help, 0})
  end

  @doc """
  Returns the usage messages for the command that matches on `name`.
  """
  @spec usage(routes, String.t()) :: {:ok, [String.t()] | nil} | :error
  def usage(routes, name) do
    resolve_and_apply(routes, name, {:usage, 0})
  end

  @doc """
  Performs a lookup by `name` on `router`.
  """
  @spec resolve(routes, String.t()) :: {:ok, Command.t()} | :error
  def resolve(routes, name) do
    Map.fetch(routes, name)
  end

  defp resolve_and_apply(routes, name, {method, arity}, params \\ []) do
    with {:ok, route} <- resolve(routes, name) do
      return =
        if function_exported?(route, method, arity) do
          apply(route, method, params)
        end

      {:ok, return}
    end
  end
end
