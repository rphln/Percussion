defmodule Percussion.Router do
  @moduledoc """
  Command routing specification.
  """

  alias Percussion.Command
  alias Percussion.Dispatcher
  alias Percussion.Request
  alias Percussion.Router

  @typedoc "Alias map."
  @type aliases :: %{String.t() => String.t()}

  @typedoc "Transformations to apply before dispatching."
  @type pipeline :: [Request.transform()]

  @typedoc "Route specification."
  @type route :: Router.t() | Command.t()

  @typedoc "Route map."
  @type routes :: %{String.t() => route}

  @type t :: %Router{
          aliases: aliases,
          pipeline: pipeline,
          routes: routes
        }

  defstruct aliases: %{},
            pipeline: [],
            routes: %{}

  @doc """
  Returns the router specification for the given `entries`.
  """
  @spec compile([route], Keyword.t()) :: t
  def compile(entries, opts \\ []) do
    pipeline = opts[:pipe] || []

    %Router{
      aliases: aliases_for(entries),
      pipeline: pipeline,
      routes: routes_for(entries)
    }
  end

  @doc """
  Returns the alias map for the given `routes`.
  """
  @spec aliases_for([route]) :: aliases
  def aliases_for(entries) do
    Enum.reduce(entries, %{}, fn route, map ->
      # This uses the first alias of `route` as a way to generate an unique name for
      # the route, in order to be consistent with `routes_for/1`.
      aliases = [name | _rest] = Dispatcher.aliases(route)

      for key <- aliases, into: map do
        {key, name}
      end
    end)
  end

  @doc """
  Returns the routing map for the given `entries`.
  """
  @spec routes_for([route]) :: routes
  def routes_for(entries) do
    for route <- entries, into: %{} do
      # Consistently generates a route name; see `aliases_for/1`.
      [name | _rest] = Dispatcher.aliases(route)
      {name, route}
    end
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
    def aliases(router) do
      Map.keys(router.aliases)
    end

    def describe(router, name) do
      with {:ok, route} <- Router.resolve(router, name),
           {:ok, text} <- Dispatcher.describe(route, name) do
        {:ok, text}
      end
    end

    def execute(router, request) do
      # Executing the pipeline beforehand ensures any possible command name change in
      # the router pipeline works as expected.
      request = Request.pipe(request, router.pipeline)

      with {:ok, route} <- Router.resolve(router, request.invoked_with),
           {:ok, response} <- Dispatcher.execute(route, request) do
        {:ok, response}
      end
    end
  end
end
