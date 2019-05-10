defmodule Percussion.Router do
  @moduledoc """
  Macro helpers to define command routes and pipelines.

  Each command and redirect may have their `Percussion.Request` pass through
  a transformation pipeline, specified through their respective `:preamble` option.

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

  @doc """
  Defines a command dispatcher that matches on `match`.

  The variable `request` is available in the command context and represents the
  `Percussion.Request` that triggered the call.

  ## Examples

      command "hello"

      command "foo",
        preamble: [help: @help, whitelist_guilds: [123_456_789, 987_654_321]]

      # Adding a wildcard command, even if empty, is a good idea to prevent match
      # errors.
      command _any, as: :wildcard

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
  defmacro command(match, options \\ [])

  defmacro command(match, options) do
    preamble = Keyword.get(options, :preamble, [])
    function = Keyword.get_lazy(options, :as, fn -> String.to_atom(match) end)

    do_command(match, quote(do: __MODULE__), function, preamble)
  end

  @doc """
  Redirects a command request another router.

  ## Examples

      redirect "foo", FooHandler

      # Pipes through `trim/2` and `prettify/2` before redirecting.
      redirect "bar", [:trim, :prettify], to: FooHandler

      # Wildcard redirections are also possible.
      redirect _any, FooHandler

  """
  defmacro redirect(match, module, options \\ [])

  defmacro redirect(match, module, options) do
    preamble = Keyword.get(options, :preamble, [])
    function = Keyword.get(options, :as, :dispatch)

    do_command(match, module, function, preamble)
  end

  defp do_command(match, module, function, decorators) do
    body =
      quote do
        unquote(module).unquote(function)(request)
      end

    quote do
      def dispatch(%Percussion.Request{invoked_with: unquote(match)} = request, nil) do
        unquote(wrap(body, decorators))
      end
    end
  end

  ## Decorator functions.

  defp wrap(body, decorators) do
    decorators
    |> Enum.reverse()
    |> Enum.reduce(body, fn decorator, acc ->
      decorator
      |> ensure_decorator_opts()
      |> quote_decorator_call()
      |> quote_halt_handler(acc)
    end)
  end

  defp quote_halt_handler(call, body) do
    quote do
      case unquote(call) do
        %Percussion.Request{halt: true} = request ->
          request

        %Percussion.Request{halt: false} = request ->
          unquote(body)

        _ ->
          raise unquote("Expected `#{Macro.to_string(call)}` to return a `Percussion.Request`.")
      end
    end
  end

  ## Helper functions.

  defp quote_decorator_call({fun, opt}) do
    quote do: unquote(fun)(request, unquote(opt))
  end

  defp ensure_decorator_opts(fun) when is_atom(fun) do
    {fun, nil}
  end

  defp ensure_decorator_opts({fun, _opt} = decorator) when is_atom(fun) do
    decorator
  end

  defp ensure_decorator_opts(decorator) do
    raise ArgumentError,
      message: "`#{inspect(decorator)}` must be an atom or a tuple of an atom and term."
  end
end
