defmodule Percussion.Converters do
  @moduledoc """
  Utility functions for converting Discord mentions or strings into useful formats.
  """

  alias Nostrum.Snowflake

  @channel_regex ~r/<#([0-9]+)>$/i
  @role_mention_regex ~r/<@&([0-9]+)>$/i
  @user_mention_regex ~r/<@!?([0-9]+)>$/i
  @emoji_regex ~r/<:(?:\S+):([0-9]+)>$/i

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
  def user_mention_to_id(text) when is_bitstring(text) do
    with [_text, match] <- Regex.run(@user_mention_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
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
  def role_mention_to_id(text) when is_bitstring(text) do
    with [_text, match] <- Regex.run(@role_mention_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
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
  def channel_to_id(text) when is_bitstring(text) do
    with [_text, match] <- Regex.run(@channel_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end

  @doc """
  Converts a formatted Discord emoji to a `t:Nostrum.Snowflake.t/0`.

  ## Examples

      iex> Percussion.Converters.emoji_to_id("<:thonk:123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.emoji_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.emoji_to_id("123456789")
      :error

  """
  @spec emoji_to_id(String.t()) :: {:ok, Snowflake.t()} | :error
  def emoji_to_id(text) when is_bitstring(text) do
    with [_text, match] <- Regex.run(@emoji_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end
end
