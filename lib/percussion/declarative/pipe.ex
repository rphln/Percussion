defmodule Percussion.Declarative.Pipe do
  @moduledoc """
  Sends the request through a pipeline before dispatching.
  """

  alias Percussion.Declarative.Dispatcher
  alias Percussion.Declarative.Pipe
  alias Percussion.Request

  @typedoc "Target dispatcher."
  @type child :: Dispatcher.t()

  @typedoc "Actions to execute on the request."
  @type pipeline :: [Request.step()]

  @type t :: %Pipe{
          child: child,
          pipeline: pipeline
        }

  @enforce_keys [:child, :pipeline]

  defstruct [:child, :pipeline]

  @doc """
  Builds a new pipeline dispatcher.
  """
  @spec new(child, pipeline) :: t
  def new(child, pipeline) do
    %Pipe{
      child: child,
      pipeline: pipeline
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
      response = Request.pipe(request, pipe.pipeline)
      Dispatcher.execute(pipe.child, response)
    end
  end
end
