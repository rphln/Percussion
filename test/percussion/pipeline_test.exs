defmodule Percussion.PipelineTest do
  use ExUnit.Case, async: true

  require Percussion.Pipeline

  alias Percussion.Pipeline
  alias Percussion.Request

  setup_all do
    %{
      request: %Request{invoked_with: ""},
      halted: Request.halt(%Request{invoked_with: ""})
    }
  end

  describe "fold/2" do
    setup do
      %{
        ordered: [
          &Request.assign(&1, call: 1),
          &Request.halt/1,
          &Request.assign(&1, call: 2)
        ],
        invalid: [
          fn request -> Map.from_struct(request) end
        ]
      }
    end

    test "evaluates correctly", context do
      response = Pipeline.fold(context.ordered, context.request)

      assert response.halt == true
      assert response.assigns.call == 1
    end

    test "no-op if halted", context do
      response = Pipeline.fold(context.ordered, context.halted)

      assert context.halted == response
    end

    test "rejects non-Request", context do
      assert_raise ArgumentError, fn ->
        Pipeline.fold(context.invalid, context.request)
      end
    end
  end

  describe "expand/1" do
    defp assign(request, value) do
      Request.assign(request, assigned: value)
    end

    test "works", context do
      reference = :rand.uniform()

      response =
        [assign: reference]
        |> Pipeline.expand()
        |> Pipeline.fold(context.request)

      assert assign(context.request, reference) == response
    end

    test "expands nil", context do
      response =
        [:assign]
        |> Pipeline.expand()
        |> Pipeline.fold(context.request)

      assert assign(context.request, nil) == response
    end
  end
end
