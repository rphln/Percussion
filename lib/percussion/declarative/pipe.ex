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

  @doc """
  Adds `step` into the pipeline.

  Note that, when added this way, `step` is called first.
  """
  @spec put(t, Request.step()) :: t
  def put(pipe, step) do
    update_in(pipe.pipeline, &[step | &1])
  end

  defimpl Dispatcher do
    def aliases(%Pipe{child: child}) do
      Dispatcher.aliases(child)
    end

    def execute(%Pipe{child: child, pipeline: pipeline}, %Request{} = request) do
      response = Request.pipe(request, pipeline)
      Dispatcher.execute(child, response)
    end

    def describe(%Pipe{child: child}) do
      Dispatcher.describe(child)
    end
  end
end
