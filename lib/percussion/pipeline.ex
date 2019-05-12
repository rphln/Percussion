defmodule Percussion.Pipeline do
  @moduledoc false

  defmacro with(decorators, do: expr) do
    {:with, meta, body} = wrap_with(expr)
    {:with, meta, inject(decorators, body)}
  end

  defp inject(decorators, expr) do
    decorators
    |> Enum.reverse()
    |> Enum.reduce(expr, fn decorator, acc ->
      [decorator |> ensure_decorator_opts() |> to_clause() | acc]
    end)
  end

  defp to_clause({fun, opt}) do
    quote do
      %Percussion.Request{halt: false} = request <- unquote(fun)(request, unquote(opt))
    end
  end

  defp wrap_with(expr) do
    quote do
      with do
        unquote(expr)
      else
        %Percussion.Request{halt: true} = request ->
          request

        _ ->
          raise unquote("Expected decorators to return a `Percussion.Request`.")
      end
    end
  end

  ## Helper functions.

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