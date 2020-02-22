defmodule Percussion.Decorators do
  @moduledoc """
  Built-in command decorators.
  """

  require Logger

  alias Percussion.Request

  @doc """
  Requires the command to be called in a guild.
  """
  @spec guild_only :: Request.step()
  def guild_only do
    fn
      request = %Request{guild_id: nil} ->
        Request.halt(request, "This command can only be used in guilds.")

      request = %Request{} ->
        request
    end
  end

  @doc """
  Requires the command to be called in a direct message.
  """
  @spec direct_message_only :: Request.step()
  def direct_message_only do
    fn
      request = %Request{guild_id: nil} ->
        request

      request = %Request{} ->
        Request.halt(request, "This command can't be used in guilds.")
    end
  end

  @doc """
  Prevents the command from being called in non-whitelisted guilds.

  The command can still be used in direct messages.
  """
  @spec whitelist_guilds([Request.guild_id()]) :: Request.step()
  def whitelist_guilds(whitelist) do
    fn %Request{guild_id: guild_id} = request ->
      if is_nil(guild_id) or guild_id in whitelist do
        request
      else
        Request.halt(request, "This command can't be used in this server.")
      end
    end
  end

  @doc """
  Combines `guild_only/1` and `whitelist_guilds/1`.
  """
  @spec whitelisted_guilds_only([Request.guild_id()]) :: Request.step()
  def whitelisted_guilds_only(whitelist) do
    fn %Request{} = request ->
      request
      |> Request.and_then(guild_only())
      |> Request.and_then(whitelist_guilds(whitelist))
    end
  end

  @doc """
  Prevents the command from being called by non-whitelisted users.
  """
  @spec whitelist_users([Request.author_id()]) :: Request.step()
  def whitelist_users(whitelist) do
    fn %Request{author_id: author_id} = request ->
      if author_id in whitelist do
        request
      else
        Request.halt(request, "Permission denied.")
      end
    end
  end
end
