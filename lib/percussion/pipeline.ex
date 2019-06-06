defmodule Percussion.Pipeline do
  @moduledoc false

  @doc """
  Expands a pipeline in shorthand form.
  """
  defmacro expand(pipeline) do
    for pipe <- pipeline do
      pipe |> ensure_pipe_opts() |> to_clause()
    end
  end

  defp to_clause({fun, opt}) do
    quote do
      fn request -> unquote(fun)(request, unquote(opt)) end
    end
  end

  defp ensure_pipe_opts(fun) when is_atom(fun) do
    {fun, nil}
  end

  defp ensure_pipe_opts({fun, _opt} = pipe) when is_atom(fun) do
    pipe
  end

  defp ensure_pipe_opts(pipe) do
    raise ArgumentError,
      message: "`#{inspect(pipe)}` must be an atom or a tuple of an atom and term."
  end
end
