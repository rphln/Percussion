defmodule Percussion.Decorators do
  @moduledoc """
  Built-in command decorators.
  """

  alias Nostrum.Snowflake
  alias Percussion.Request

  @doc """
  Adds `--help` as a possible argument to the command.
  """
  @spec help(String.t()) :: Request.transform()
  def help(contents) do
    fn %Request{arguments: arguments} = request ->
      if "--help" in arguments do
        Request.halt(request, contents)
      else
        request
      end
    end
  end

  @doc """
  Requires the command to be called in only a guild, or only in DMs.
  """
  @spec in_guild?(boolean) :: Request.transform()
  def in_guild?(required) do
    fn %Request{message: message} = request ->
      cond do
        required and is_nil(message.guild_id) ->
          Request.halt(request, "This command can only be used in guilds.")

        not required and not is_nil(message.guild_id) ->
          Request.halt(request, "This command can't be used in guilds.")

        true ->
          request
      end
    end
  end

  @doc """
  Prevents the command from being called in non-whitelisted guilds.

  Note that it can still be used in DMs.
  """
  @spec whitelist_guilds([Snowflake.t()]) :: Request.transform()
  def whitelist_guilds(whitelist) do
    fn %Request{message: message} = request ->
      cond do
        is_nil(message.guild_id) ->
          request

        message.guild_id in whitelist ->
          request

        true ->
          Request.halt(request, "This command can't be used in this server.")
      end
    end
  end

  @doc """
  Combines `in_guild?/2` and `whitelist_guilds/2`.
  """
  @spec in_whitelisted_guild?([Snowflake.t()]) :: Request.transform()
  def in_whitelisted_guild?(whitelist) do
    guild = in_guild?(true)
    whitelist = whitelist_guilds(whitelist)

    fn request ->
      request
      |> Request.map(guild)
      |> Request.map(whitelist)
    end
  end

  @doc """
  Prevents the command from being called by non-whitelisted users.
  """
  @spec whitelist_users([Snowflake.t()]) :: Request.transform()
  def whitelist_users(whitelist) do
    fn %Request{message: message} = request ->
      if message.author.id in whitelist do
        request
      else
        Request.halt(request, "Permission denied.")
      end
    end
  end
end
