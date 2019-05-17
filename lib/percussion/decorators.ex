defmodule Percussion.Decorators do
  @moduledoc """
  Built-in command decorators.
  """

  alias Percussion.Request

  @doc """
  Adds `--help` as a possible argument to the command.
  """
  def help(%Request{arguments: arguments} = request, contents) do
    if "--help" in arguments do
      Request.halt(request, contents)
    else
      request
    end
  end

  @doc """
  Requires the command to be called in only a guild, or only in DMs.
  """
  def in_guild?(%Request{message: message} = request, required) do
    cond do
      required and is_nil(message.guild_id) ->
        Request.halt(request, "This command can only be used in guilds.")

      not required and not is_nil(message.guild_id) ->
        Request.halt(request, "This command can't be used in guilds.")

      true ->
        request
    end
  end

  @doc """
  Prevents the command from being called in non-whitelisted guilds.

  Note that it can still be used in DMs.
  """
  def whitelist_guilds(%Request{message: message} = request, whitelist) do
    cond do
      is_nil(message.guild_id) ->
        request

      message.guild_id in whitelist ->
        request

      true ->
        Request.halt(request, "This command can't be used in this server.")
    end
  end

  @doc """
  Combines `in_guild?/2` and `whitelist_guilds/2`.
  """
  def in_whitelisted_guild?(%Request{} = request, whitelist) do
    with %Request{halt: false} = request <- in_guild?(request, true),
         %Request{halt: false} = request <- whitelist_guilds(request, whitelist) do
      request
    end
  end

  @doc """
  Prevents the command from being called by non-whitelisted users.
  """
  def whitelist_users(%Request{message: message} = request, whitelist) do
    if message.author.id in whitelist do
      request
    else
      Request.halt(request, "Permission denied.")
    end
  end
end
