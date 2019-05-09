defmodule Percussion.Router do
  @moduledoc """
  Macro helpers to define command routes and pipelines.
  """

  @doc """
  Defines a command dispatcher that matches on `match`.

  The variable `request` is available in the command context and represents the
  `Percussion.Request` that triggered the call.

  ## Examples

      command "hello" do
        Request.reply(request, "Hello world!")
      end

      command "foo", in_guild: true, whitelist_guilds: [123_456_789, 987_654_321] do
        Request.reply(request, "bar")
      end

  """
  defmacro command(match, decorators \\ [], do: body) do
    do_command(match, body, decorators)
  end

  @doc """
  Redirects a command request another router.

  ## Examples

      redirect "foo", to: FooHandler

      # Pipes through `trim/2` and `prettify/2` before redirecting.
      redirect "bar", [:trim, :prettify], to: FooHandler

      # Wildcard redirections are also possible.
      redirect _any, to: FooHandler

  """
  defmacro redirect(match, decorators \\ [], to: module) do
    body =
      quote do
        unquote(module).dispatch(unquote(match), nil)
      end

    do_command(match, body, decorators)
  end

  defp do_command(match, body, decorators) do
    quote do
      def dispatch(%Percussion.Request{invoked_with: unquote(match)} = request, nil) do
        var!(request) = request
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
      request = var!(request)

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
