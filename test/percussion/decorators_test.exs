defmodule Percussion.DecoratorsTest do
  use ExUnit.Case, async: true

  alias Percussion.Decorators
  alias Percussion.Request

  describe "in_guild?/2" do
    setup [:guilds]

    test "halts if message was not sent in a guild", context do
      assert %Request{halt: true} = context.no_guild |> Decorators.in_guild?(true)
      assert %Request{halt: false} = context.in_guild |> Decorators.in_guild?(true)
    end

    test "halts if message was sent in a guild", context do
      assert %Request{halt: true} = context.in_guild |> Decorators.in_guild?(false)
      assert %Request{halt: false} = context.no_guild |> Decorators.in_guild?(false)
    end
  end

  def guilds(_context) do
    %{
      in_guild: %Request{message: %{guild_id: 1_234_567_890}},
      no_guild: %Request{message: %{guild_id: nil}}
    }
  end
end
