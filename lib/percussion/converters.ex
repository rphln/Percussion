defmodule Percussion.Converters do
  @channel_regex ~r/<#([0-9]+)>$/i
  @role_mention_regex ~r/<@&([0-9]+)>$/i
  @user_mention_regex ~r/<@!?([0-9]+)>$/i

  @doc """
  Converts a formatted Discord user mention to a standalone id.

  ## Examples

      iex> Percussion.Converters.user_mention_to_id("<@123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.user_mention_to_id("<@!123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.user_mention_to_id("123456789")
      {:error, "Not an user mention."}

  """
  def user_mention_to_id(text) do
    with [_text, match] <- Regex.run(@user_mention_regex, text),
         {id, ""} <- Integer.parse(match) do
      {:ok, id}
    else
      _ ->
        {:error, "Not an user mention."}
    end
  end

  @doc """
  Converts a formatted Discord role mention to a standalone id.

  ## Examples

      iex> Percussion.Converters.role_mention_to_id("<@&123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.role_mention_to_id("<@123456789>")
      {:error, "Not a role mention."}

      iex> Percussion.Converters.role_mention_to_id("123456789")
      {:error, "Not a role mention."}

  """
  def role_mention_to_id(text) do
    with [_text, match] <- Regex.run(@role_mention_regex, text),
         {id, ""} <- Integer.parse(match) do
      {:ok, id}
    else
      _ ->
        {:error, "Not a role mention."}
    end
  end

  @doc """
  Converts a formatted Discord role mention to a standalone id.

  ## Examples

      iex> Percussion.Converters.channel_to_id("<#123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.channel_to_id("<@123456789>")
      {:error, "Not a channel."}

      iex> Percussion.Converters.channel_to_id("123456789")
      {:error, "Not a channel."}

  """
  def channel_to_id(text) do
    with [_text, match] <- Regex.run(@channel_regex, text),
         {id, ""} <- Integer.parse(match) do
      {:ok, id}
    else
      _ ->
        {:error, "Not a channel."}
    end
  end
end
