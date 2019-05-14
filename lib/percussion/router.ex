defmodule Percussion.Router do
  @moduledoc """
  Macro helpers to define command routes and pipelines.

  Decorator functions must accept an request and an option argument, and return the
  transformed request. If the `halt` attribute is set on the request, the pipeline
  will stop prematurely.

  ## Examples

      def ignore(%Request{} = request, _opt) do
        Request.halt(request, "Not implemented!")
      end

      def whitelist_guilds(%Request{message: message} = request, whitelist) do
        if message.guild_id in whitelist do
          request
        else
          Request.halt(request, "This command can't be used in this server.")
        end
      end

      def help(%Request{arguments: arguments} = request, help) do
        if "--help" in arguments do
          Request.halt(request, help)
        else
          request
        end
      end

  """

  @module quote(do: __MODULE__)

  @doc """
  Defines a command dispatcher that matches on `name`.

  ## Examples

      command "hello"

      # Pipes through `help` and `whitelist_guilds`.
      command "foo",
        help: @help,
        whitelist_guilds: [123_456_789, 987_654_321]

      # Passing decorators like so is also possible; in this case, their second
      # argument is nil.
      command "baz", [:ignore]

      def hello(%Request{} = request) do
        Request.reply(request, "Hello world!")
      end

      def foo(%Request{} = request) do
        Request.reply(request, "bar")
      end

  """
  defmacro command(name, decorators \\ []) when is_list(decorators) do
    quote_dispatch(name, @module, String.to_atom(name), decorators)
  end

  @doc """
  Defines a command dispatcher that matches on `name` and invokes `target`. See
  `Percussion.Router.command/2`.

  ## Examples

      match "hello", :world

      # Adding a wildcard command, even if empty, is a good idea to prevent match
      # errors.
      match _any, :wildcard

      def world(%Request{} = request) do
        Request.reply(request, "Hello world!")
      end

      def wildcard(%Request{} = request) do
        Request.reply(request, "Error! Command not found.")
      end

  """
  defmacro match(name, target, decorators \\ []) do
    quote_dispatch(name, @module, target, decorators)
  end

  @doc """
  Redirects a request another router.

  ## Examples

      redirect "foo", FooHandler

      # Pipes through `whitelist_guilds/2` before redirecting.
      redirect "bar", FooHandler, whitelist_guilds: [123_456_789, 987_654_321]

      # Wildcard redirections are also possible.
      redirect _any, FooHandler

  """
  defmacro redirect(match, module, decorators \\ []) do
    quote_dispatch(match, module, :dispatch, decorators)
  end

  defp quote_dispatch(match, module, function, decorators) do
    quote do
      require Percussion.Pipeline

      def dispatch(%Percussion.Request{invoked_with: unquote(match)} = request) do
        fun = &unquote(module).unquote(function)(&1)

        unquote(decorators)
        |> Percussion.Pipeline.expand()
        |> Percussion.Pipeline.fold(request)
        |> Percussion.Request.map(fun)
      end
    end
  end
end
