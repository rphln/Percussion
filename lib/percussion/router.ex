defmodule Percussion.Router do
  @moduledoc """
  Macro helpers to define command routes and pipelines.

  Each command and redirect may have their `Percussion.Request` pass through
  a transformation pipeline, specified through their respective `:decorators` option.

  Preamble functions must accept an request and an option argument, and return the
  transformed request. If the `halt` attribute is set on the request, the pipeline
  will stop prematurely.

  ## Examples

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
  Defines a command dispatcher that matches on `match`.

  The variable `request` is available in the command context and represents the
  `Percussion.Request` that triggered the call.

  ## Examples

      command "hello"

      # Pipes through `help` and `whitelist_guilds`.
      command "foo", help: @help, whitelist_guilds: [123_456_789, 987_654_321]

      # Adding a wildcard command, even if empty, is a good idea to prevent match
      # errors.
      command _any, :wildcard, []

      def hello(%Request{} = request) do
        Request.reply(request, "Hello world!")
      end

      def foo(%Request{} = request) do
        Request.reply(request, "bar")
      end

      def wildcard(%Request{} = request) do
        Request.reply(request, "Error! Command not found.")
      end

  """
  defmacro command(match, function, decorators)

  defmacro command(match, nil, decorators) do
    do_command(match, @module, String.to_atom(match), decorators)
  end

  defmacro command(match, function, decorators) do
    do_command(match, @module, function, decorators)
  end

  @doc """
  See `Percussion.Router.command/3`.
  """
  defmacro command(match, decorators \\ []) when is_list(decorators) do
    quote do
      command(unquote(match), nil, unquote(decorators))
    end
  end

  @doc """
  Redirects a command request another router.

  ## Examples

      redirect "foo", FooHandler

      # Pipes through `whitelist_guilds/2` before redirecting.
      redirect "bar", FooHandler, whitelist_guilds: [123_456_789, 987_654_321]

      # Wildcard redirections are also possible.
      redirect _any, FooHandler

  """
  defmacro redirect(match, module, decorators) do
    do_command(match, module, :dispatch, decorators)
  end

  defp do_command(match, module, function, decorators) do
    quote do
      def dispatch(%Percussion.Request{invoked_with: unquote(match)} = request, nil) do
        Percussion.Pipeline.with unquote(decorators) do
          unquote(module).unquote(function)(request, nil)
        end
      end
    end
  end
end
