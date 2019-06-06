defmodule Percussion.PipelineTest do
  use ExUnit.Case, async: true

  require Percussion.Pipeline

  alias Percussion.Pipeline
  alias Percussion.Request

  setup_all do
    %{request: %Request{invoked_with: ""}}
  end

  describe "expand/1" do
    defp assign(request, value) do
      Request.assign(request, assigned: value)
    end

    test "works", context do
      reference = :rand.uniform()
      pipe = Pipeline.expand(assign: reference)

      assert assign(context.request, reference) == Request.pipe(context.request, pipe)
    end

    test "expands nil", context do
      pipe = Pipeline.expand([:assign])

      assert assign(context.request, nil) == Request.pipe(context.request, pipe)
    end
  end
end
