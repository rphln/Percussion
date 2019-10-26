defmodule Percussion.Utils do
  @moduledoc """
  Utility functions that don't warrant their own modules, but are likely useful for most
  bots.
  """

  alias Nostrum.Api
  alias Nostrum.Struct.Message

  alias Percussion.Request

  @doc """
  Tries splitting the given `text` with `OptionParser.split/1`, and falls back to
  `String.split/1` if it fails.

  ## Examples

      iex> Percussion.Utils.split(~s[choose "lorem ipsum" "hello world"])
      ["choose", "lorem ipsum", "hello world"]

      iex> Percussion.Utils.split(~s[I'm a bot])
      ["I'm", "a", "bot"]

  """
  @spec split(String.t()) :: [String.t()]
  def split(text) do
    OptionParser.split(text)
  rescue
    _ in RuntimeError -> String.split(text)
  end

  @doc """
  Creates a `t:Percussion.Request.t/0` from a `t:Nostrum.Struct.Message.t/0`.

  Argument `contents` must be the unprefixed contents of the message that triggered
  this command. Note that enforcing that `message` and `contents` matches is up to the
  caller.
  """
  @spec to_request(Message.t(), String.t()) :: Request.t()
  def to_request(%Message{} = message, contents) do
    with [command | arguments] <- split(contents) do
      %Request{
        arguments: arguments,
        author_id: message.author_id,
        channel_id: message.channel_id,
        guild_id: message.guild_id,
        invoked_with: command,
        message: message,
        message_id: message.id
      }
    end
  end

  @doc """
  Replies a request to the respective channel.
  """
  @spec create_message(Request.t()) :: {:ok, Message.t()} | Api.error()
  def create_message(%Request{} = request) do
    Request.send_response(request, &do_create_message/1)
  end

  defp do_create_message(%Request{response: response, message: message} = request) do
    unless is_nil(response) do
      Api.create_message(message, response)
    end

    request
  end
end
