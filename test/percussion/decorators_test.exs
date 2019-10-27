defmodule Percussion.DecoratorsTest do
  use ExUnit.Case, async: true

  alias Percussion.Decorators, as: Subject
  alias Percussion.Request

  setup do
    guilds = %{
      foo: 1_234_567_890,
      bar: 9_876_543_210
    }

    authors = %{
      alice: 1_234_567_890,
      bob: 9_876_543_210
    }

    requests = %{
      to_foo: %Request{
        invoked_with: "",
        guild_id: guilds.foo
      },
      to_bar: %Request{
        invoked_with: "",
        guild_id: guilds.bar
      },
      to_nil: %Request{
        invoked_with: "",
        guild_id: nil
      },
      from_alice: %Request{
        invoked_with: "",
        author_id: authors.alice
      },
      from_bob: %Request{
        invoked_with: "",
        author_id: authors.bob
      }
    }

    %{authors: authors, guilds: guilds, requests: requests}
  end

  describe "direct_message_only/1" do
    test "works correctly", %{requests: requests} do
      predicate = Subject.direct_message_only()

      assert %{halt: false} = predicate.(requests.to_nil)
      assert %{halt: true} = predicate.(requests.to_foo)
    end
  end

  describe "guild_only/1" do
    test "works correctly", %{requests: requests} do
      predicate = Subject.guild_only()

      assert %{halt: true} = predicate.(requests.to_nil)
      assert %{halt: false} = predicate.(requests.to_foo)
    end
  end

  describe "whitelist_guilds/2" do
    test "filters correctly", %{requests: requests, guilds: guilds} do
      predicate = Subject.whitelist_guilds([guilds.bar])

      assert %{halt: true} = predicate.(requests.to_foo)
      assert %{halt: false} = predicate.(requests.to_bar)
    end

    test "allows DMs", %{requests: requests, guilds: guilds} do
      predicate = Subject.whitelist_guilds([guilds.bar])

      assert %{halt: false} = predicate.(requests.to_nil)
    end
  end

  describe "whitelisted_guilds_only/2" do
    test "filters correctly", %{requests: requests, guilds: guilds} do
      predicate = Subject.whitelisted_guilds_only([guilds.bar])

      assert %{halt: true} = predicate.(requests.to_foo)
      assert %{halt: false} = predicate.(requests.to_bar)
    end

    test "disallows DMs", %{requests: requests, guilds: guilds} do
      predicate = Subject.whitelisted_guilds_only([guilds.bar])

      assert %{halt: true} = predicate.(requests.to_nil)
    end
  end

  describe "whitelist_users/2" do
    test "filters correctly", %{requests: requests, authors: authors} do
      predicate = Subject.whitelist_users([authors.alice])

      assert %{halt: false} = predicate.(requests.from_alice)
      assert %{halt: true} = predicate.(requests.from_bob)
    end
  end
end
