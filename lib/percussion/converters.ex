defmodule Percussion.Converters do
  @moduledoc """
  Utility functions for converting Discord mentions or strings into useful formats.
  """

  alias Nostrum.Snowflake

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
      :error

  """
  @spec user_mention_to_id(String.t()) :: Snowflake.t()
  def user_mention_to_id(text) do
    with [_text, match] <- Regex.run(@user_mention_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end

  @doc """
  Converts a formatted Discord role mention to a standalone id.

  ## Examples

      iex> Percussion.Converters.role_mention_to_id("<@&123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.role_mention_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.role_mention_to_id("123456789")
      :error

  """
  @spec role_mention_to_id(String.t()) :: Snowflake.t()
  def role_mention_to_id(text) do
    with [_text, match] <- Regex.run(@role_mention_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end

  @doc """
  Converts a formatted Discord role mention to a standalone id.

  ## Examples

      iex> Percussion.Converters.channel_to_id("<#123456789>")
      {:ok, 123456789}

      iex> Percussion.Converters.channel_to_id("<@123456789>")
      :error

      iex> Percussion.Converters.channel_to_id("123456789")
      :error

  """
  @spec channel_to_id(String.t()) :: Snowflake.t()
  def channel_to_id(text) do
    with [_text, match] <- Regex.run(@channel_regex, text) do
      Snowflake.cast(match)
    else
      _ -> :error
    end
  end
end
