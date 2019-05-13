defmodule Percussion.Decorators do
  alias Percussion.Request

  alias Nostrum.Api
  alias Nostrum.Cache.GuildCache

  def help(%Request{arguments: arguments} = request, help) do
    if "--help" in arguments do
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

    keys = Enum.map(arguments, &casefold/1)

    roles =
      roles
      |> Map.take(keys)
      |> Map.values()

    Request.assign(request, roles: roles)
  end

  @doc """
  Limits matched roles to the whitelist. Must be used in conjunction to
  `parse_role_names/2`.
  """
  def whitelist_roles(%Request{assigns: assigns} = request, whitelist) do
    if match = Enum.find(assigns.roles, &(&1.name not in whitelist)) do
      Request.halt(request, "Error! Role `#{match.name}` is not whitelisted.")
    else
      request
    end
  end

  defp casefold(string) when is_bitstring(string) do
    string |> String.normalize(:nfd) |> String.downcase()
  end
end
