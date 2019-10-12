defmodule Percussion do
  @moduledoc """
  Provides templates for common patterns among bots.
  """

  @doc """
  When used, applies the specified template.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def command do
    quote do
      @behaviour Percussion.Command

      alias Percussion.Request

      import Percussion.Decorators
      import Percussion.Request

      @doc """
      Executes the command on `request` after passing it through the pipeline.
      """
      @spec handle(Request.t()) :: Request.into()
      def handle(request)

      @doc """
      Steps that a request should pass through before being mapped to `handle/1`.
      """
      @spec pipeline :: [Request.step()]
      def pipeline do
        []
      end

      def usage do
        []
      end

      if @moduledoc do
        def help do
          @moduledoc
        end
      end

      def call(request) do
        request
        |> Request.pipe(pipeline())
        |> Request.and_then(&handle/1)
      end

      defoverridable Percussion.Command
      defoverridable pipeline: 0, handle: 1
    end
  end
end
