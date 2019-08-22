defmodule Percussion.Declarative.Router do
  @moduledoc """
  Command routing specification.
  """

  alias Percussion.Declarative.Dispatcher
  alias Percussion.Declarative.Router

  @typedoc "Name resolution table."
  @type aliases :: %{String.t() => String.t()}

  @typedoc "Route specification."
  @type route :: Dispatcher.t()

  @typedoc "Routing table."
  @type routes :: %{String.t() => route}

  @type t :: %Router{
          aliases: aliases,
          routes: routes
        }

  defstruct aliases: %{},
            routes: %{}

  @doc """
  Returns the router specification for the given `entries`.
  """
  @spec new([route]) :: t
  def new(entries) do
    Enum.reduce(entries, %Router{}, &put(&2, &1))
  end

  @doc """
  Inserts `entry` into the router table.
  """
  @spec put(t, route) :: t
  def put(router, entry) do
    router
    |> put_route(entry)
    |> put_aliases(entry)
  end

  defp put_route(router, entry) do
    name = route_name(entry)
    routes = Map.put(router.routes, name, entry)

    %Router{router | routes: routes}
  end

  defp put_aliases(router, entry) do
    name = route_name(entry)

    aliases =
      entry
      |> Dispatcher.aliases()
      |> Enum.map(&{&1, name})
      |> Enum.into(router.aliases)

    %Router{router | aliases: aliases}
  end

  # Consistently generates a route name.
  defp route_name(route) do
    [name | _rest] = Dispatcher.aliases(route)
    name
  end

  @doc """
  Performs a lookup by `name` on `router`.
  """
  @spec resolve(t, String.t()) :: {:ok, route} | :error
  def resolve(router, name) do
    # This is on purpose, so non-existing command requests are mapped to `nil`, which
    # then could be handled by a "match-all" command that has `nil` as an alias.
    key = Map.get(router.aliases, name)
    Map.fetch(router.routes, key)
  end

  defimpl Dispatcher do
    def aliases(%Router{aliases: aliases}) do
      Map.keys(aliases)
    end

    def describe(%Router{routes: routes}) do
      Enum.reduce(routes, %{}, fn {_name, route}, accumulator ->
        route
        |> Dispatcher.describe()
        |> Map.merge(accumulator)
      end)
    end

    def execute(%Router{} = router, request) do
      with {:ok, route} <- Router.resolve(router, request.invoked_with) do
        Dispatcher.execute(route, request)
      end
    end
  end
end
