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
      assert %{halt: false} = Subject.in_guild?(requests.to_nil, false)
      assert %{halt: true} = Subject.in_guild?(requests.to_foo, false)
    end

    test "halts if message was not sent in a guild", %{requests: requests} do
      assert %{halt: true} = Subject.in_guild?(requests.to_nil, true)
      assert %{halt: false} = Subject.in_guild?(requests.to_foo, true)
    end
  end

  describe "whitelist_guilds/2" do
    test "filters correctly", %{requests: requests, guilds: guilds} do
      assert %{halt: true} = Subject.whitelist_guilds(requests.to_foo, [guilds.bar])
      assert %{halt: false} = Subject.whitelist_guilds(requests.to_foo, [guilds.foo])
    end

    test "allows DMs", %{requests: requests, guilds: guilds} do
      assert %{halt: false} = Subject.whitelist_guilds(requests.to_nil, [guilds.bar])
    end
  end

  describe "in_whitelisted_guild?/2" do
    test "filters correctly", %{requests: requests, guilds: guilds} do
      assert %{halt: true} = Subject.in_whitelisted_guild?(requests.to_foo, [guilds.bar])
      assert %{halt: false} = Subject.in_whitelisted_guild?(requests.to_foo, [guilds.foo])
    end

    test "disallows DMs", %{requests: requests, guilds: guilds} do
      assert %{halt: true} = Subject.in_whitelisted_guild?(requests.to_nil, [guilds.foo])
    end
  end

  describe "whitelist_users/2" do
    test "filters correctly", %{requests: requests, authors: authors} do
      assert %{halt: false} = Subject.whitelist_users(requests.from_alice, [authors.alice])
      assert %{halt: true} = Subject.whitelist_users(requests.from_bob, [authors.alice])
    end
  end

  describe "help/2" do
    @message "Hello world!"

    test "matches correctly", %{requests: requests} do
      assert %{halt: true, response: @message} = Subject.help(requests.help, @message)
    end

    test "ignores correctly", %{requests: requests} do
      assert requests.from_alice == Subject.help(requests.from_alice, @message)
    end
  end
end
