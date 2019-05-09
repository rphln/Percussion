defmodule Percussion.Decorators do
  alias Percussion.Request
  alias Percussion.Utils

  alias Nostrum.Api
  alias Nostrum.Cache.GuildCache

  def help(%Request{arguments: arguments} = request, help) do
    if "--help" in arguments do
      help = Utils.to_codeblock(help, "markdown")
      Request.halt(request, help)
    else
      request
    end
  end

  @doc """
  Replies the sender with the reason for halting the command pipeline.
  """
  def send_reply(%Request{message: message, assigns: assigns} = request, nil) do
    if :response in assigns do
      Api.create_message(message, assigns.response)
    end

    request
  end

  @doc """
  Requires messages to be sent to a guild.
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
  Limits the command to the whitelisted guilds.
  """
  def whitelist_guilds(%Request{message: message} = request, whitelist) do
    if message.guild_id in whitelist do
      request
    else
      Request.halt(request, "This command can't be used in this server.")
    end
  end

  @doc """
  Limits the command to users with specified permission.
  """
  def whitelist_users(%Request{message: message} = request, whitelist) do
    if message.author.id in whitelist do
      request
    else
      Request.halt(request, "Permission denied.")
    end
  end

  @doc """
  Convert role name matches in the arguments.
  """
  def parse_role_names(%Request{message: message, arguments: arguments} = request, _opts) do
    guild = GuildCache.get!(message.guild_id)

    roles =
      guild.roles
      |> Enum.map(fn {_id, role} -> {casefold(role.name), role} end)
      |> Enum.into(%{})

    matches =
      arguments
      |> Enum.map(&Map.get(roles, casefold(&1)))
      |> Enum.filter(&(&1 != nil))

    Request.assign(request, roles: matches)
  end

  defp casefold(string) when is_bitstring(string) do
    string |> String.normalize(:nfd) |> String.downcase()
  end
end
