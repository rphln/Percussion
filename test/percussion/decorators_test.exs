defmodule Percussion.DecoratorsTest do
  use ExUnit.Case, async: true

  alias Percussion.Decorators, as: Subject
  alias Percussion.Request

  alias Nostrum.Struct.Message
  alias Nostrum.Struct.User

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
        message: %Message{guild_id: guilds.foo}
      },
      to_bar: %Request{
        invoked_with: "",
        message: %Message{guild_id: guilds.bar}
      },
      to_nil: %Request{
        invoked_with: "",
        message: %Message{guild_id: nil}
      },
      from_alice: %Request{
        invoked_with: "",
        message: %Message{author: %User{id: authors.alice}}
      },
      from_bob: %Request{
        invoked_with: "",
        message: %Message{author: %User{id: authors.bob}}
      },
      help: %Request{
        invoked_with: "",
        arguments: ["--help"]
      }
    }

    %{authors: authors, guilds: guilds, requests: requests}
  end

  describe "in_guild?/2" do
    test "halts if message was sent in a guild", %{requests: requests} do
      predicate = Subject.in_guild?(false)

      assert %{halt: false} = predicate.(requests.to_nil)
      assert %{halt: true} = predicate.(requests.to_foo)
    end

    test "halts if message was not sent in a guild", %{requests: requests} do
      predicate = Subject.in_guild?(true)

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

  describe "in_whitelisted_guild?/2" do
    test "filters correctly", %{requests: requests, guilds: guilds} do
      predicate = Subject.in_whitelisted_guild?([guilds.bar])

      assert %{halt: true} = predicate.(requests.to_foo)
      assert %{halt: false} = predicate.(requests.to_bar)
    end

    test "disallows DMs", %{requests: requests, guilds: guilds} do
      predicate = Subject.in_whitelisted_guild?([guilds.bar])

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

  describe "help/2" do
    @message "Hello world!"

    test "matches correctly", %{requests: requests} do
      assert %{halt: true, response: @message} = Subject.help(@message).(requests.help)
    end

    test "ignores correctly", %{requests: requests} do
      assert requests.from_alice == Subject.help(@message).(requests.from_alice)
    end
  end
end
