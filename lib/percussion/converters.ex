defmodule Percussion.Converters do
  @moduledoc """
  Utility functions for converting Discord mentions or strings into useful formats.
  """

  alias Nostrum.Snowflake

  @animated_emoji_regex ~r/<a:(?:\S+):([0-9]+)>$/i
  @channel_regex ~r/<#([0-9]+)>$/i
  @emoji_regex ~r/<:(?:\S+):([0-9]+)>$/i
  @role_mention_regex ~r/<@&([0-9]+)>$/i
  @user_mention_regex ~r/<@!?([0-9]+)>$/i

  @doc """
  Converts a formatted Discord user mention to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.user_mention_to_id("<@123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.user_mention_to_id("<@!123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.user_mention_to_id("123456789")
      :error

  """
  @spec user_mention_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def user_mention_to_id(text) do
    parse_snowflake(@user_mention_regex, text)
  end

  @doc """
  Converts a formatted Discord role mention to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.role_mention_to_id("<@&123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.role_mention_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.role_mention_to_id("123456789")
      :error

  """
  @spec role_mention_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def role_mention_to_id(text) do
    parse_snowflake(@role_mention_regex, text)
  end

  @doc """
  Converts a formatted Discord channel mention to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.channel_to_id("<#123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.channel_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.channel_to_id("123456789")
      :error

  """
  @spec channel_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def channel_to_id(text) do
    parse_snowflake(@channel_regex, text)
  end

  @doc """
  Converts a formatted Discord static emoji to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.static_emoji_to_id("<:thonk:123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.static_emoji_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.static_emoji_to_id("123456789")
      :error

  """
  @spec static_emoji_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def static_emoji_to_id(text) do
    parse_snowflake(@emoji_regex, text)
  end

  @doc """
  Converts a formatted Discord animated emoji to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.animated_emoji_to_id("<a:thonk:123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.animated_emoji_to_id("<:thonk:123456789>")
      :error

      iex> Percussion.Converters.animated_emoji_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.animated_emoji_to_id("123456789")
      :error

  """
  @spec animated_emoji_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def animated_emoji_to_id(text) do
    parse_snowflake(@animated_emoji_regex, text)
  end

  @doc """
  Converts any formatted Discord emoji to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.emoji_to_id("<a:thonk:123456789>")
      {:animated, 123456789}

      iex> Percussion.Converters.emoji_to_id("<:thonk:123456789>")
      {:static, 123456789}

      iex> Percussion.Converters.emoji_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.emoji_to_id("123456789")
      :error

  """
  def emoji_to_id(text) do
    # Maybe write this some other way?
    with {:static, :error} <- {:static, static_emoji_to_id(text)},
         {:animated, :error} <- {:animated, animated_emoji_to_id(text)} do
      :error
    else
      {:static, {:ok, id}} ->
        {:static, id}

      {:animated, {:ok, id}} ->
        {:animated, id}
    end
  end

  defp parse_snowflake(regex, text) do
    with [_text, match] <- Regex.run(regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end
end
