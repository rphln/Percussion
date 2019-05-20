defmodule Percussion.Pipeline do
  @moduledoc false

  alias Percussion.Request

  ## Evaluation.

  @doc """
  Applies each element in `pipeline` to `request`, returning the final result.

  This function returns when an element of `pipeline` is exhausted, or if any of its
  elements halts the request.
  """
  @spec fold([(Request.t() -> Request.t())], Request.t()) :: Request.t()
  def fold(pipeline, request) do
    Enum.reduce_while(pipeline, request, &apply_pipe/2)
  end

  defp apply_pipe(fun, request) do
    case response = Request.map(request, fun) do
      %Request{halt: false} ->
        {:cont, response}

      %Request{halt: true} ->
        {:halt, response}

      _ ->
        raise ArgumentError,
          message: "Expected `#{inspect(fun)}` to return a `Percussion.Request`."
    end
  end

  ## Pipeline shorthand.

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
