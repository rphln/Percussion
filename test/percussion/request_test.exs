defmodule Percussion.RequestTest do
  use ExUnit.Case, async: true

  alias Percussion.Request

  setup_all do
    %{
      request: %Request{invoked_with: ""},
      halted: Request.halt(%Request{invoked_with: ""})
    }
  end

  describe "pipe/2" do
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
      response = Request.pipe(context.request, context.ordered)

      assert response.halt == true
      assert response.assigns.call == 1
    end

    test "no-op if halted", context do
      response = Request.pipe(context.halted, context.ordered)

      assert context.halted == response
    end

    test "rejects non-Request", context do
      assert_raise ArgumentError, fn ->
        Request.pipe(context.request, context.invalid)
      end
    end
  end
end
