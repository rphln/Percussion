defmodule Percussion.Declarative.Pipe do
  @moduledoc """
  Pipes a request through a transformation pipeline.

  See `t:Request.transform/0`.
  """

  alias Percussion.Declarative.Dispatcher
  alias Percussion.Declarative.Pipe
  alias Percussion.Request

  @typedoc "Child dispatcher."
  @type child :: Dispatcher.t()

  @typedoc "Transformations to apply before dispatching."
  @type pipes :: [Request.transform()]

  @type t :: %Pipe{
          child: child,
          pipes: pipes
        }

  @enforce_keys [:child, :pipes]

  defstruct [:child, :pipes]

  @doc """
  Builds a new pipeline dispatcher.
  """
  @spec new(child, pipes) :: t
  def new(child, pipes) do
    %Pipe{
      child: child,
      pipes: pipes
    }
  end

  defimpl Dispatcher do
    def aliases(pipe) do
      Dispatcher.aliases(pipe.child)
    end

    def describe(pipe, name) do
      Dispatcher.describe(pipe.child, name)
    end

    def execute(pipe, request) do
      response = Request.pipe(request, pipe.pipes)
      Dispatcher.execute(pipe.child, response)
    end
  end
end
