defmodule Percussion.Decorators do
  @moduledoc """
  Built-in command decorators.
  """

  alias Nostrum.Snowflake
  alias Percussion.Request

  @doc """
  Requires the command to be called in a guild.
  """
  @spec guild_only(Request.t()) :: Request.t()
  def guild_only(%Request{message: message} = request) do
    if is_nil(message.guild_id) do
      Request.halt(request, "This command can only be used in guilds.")
    else
      request
    end
  end

  @doc """
  Requires the command to be called in a direct message.
  """
  @spec direct_message_only(Request.t()) :: Request.t()
  def direct_message_only(%Request{message: message} = request) do
    if is_nil(message.guild_id) do
      request
    else
      Request.halt(request, "This command can't be used in guilds.")
    end
  end

  @doc """
  Prevents the command from being called in non-whitelisted guilds.

  Note that it can still be used in DMs.
  """
  @spec whitelist_guilds([Snowflake.t()]) :: Request.step()
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
  Combines `guild_only/1` and `whitelist_guilds/1`.
  """
  @spec whitelisted_guilds_only([Snowflake.t()]) :: Request.step()
  def whitelisted_guilds_only(whitelist) do
    whitelist = whitelist_guilds(whitelist)

    fn request ->
      request
      |> Request.map(&guild_only/1)
      |> Request.map(whitelist)
    end
  end

  @doc """
  Prevents the command from being called by non-whitelisted users.
  """
  @spec whitelist_users([Snowflake.t()]) :: Request.step()
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
