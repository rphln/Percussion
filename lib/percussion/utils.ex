defmodule Percussion.Utils do
  def split(text) do
    OptionParser.split(text)
  rescue
    _ in RuntimeError -> String.split(text)
  end

  def casefold(string) when is_bitstring(string) do
    string
    |> String.normalize(:nfd)
    |> String.downcase()
  end

  def guild_roles_by_name(%Percussion.Request{message: message}) do
    message.guild_id
    |> Nostrum.GuildCache.get!()
    |> guild_roles_by_name()
  end

  def guild_roles_by_name(guild) do
    guild.roles
    |> Enum.map(fn {_id, role} -> {casefold(role.name), role} end)
    |> Enum.into(%{})
  end
end
