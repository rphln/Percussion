defmodule Percussion.Utils do
  @moduledoc """
  Helpers which aren't particularly critical to the library and don't warrant their own
  modules.
  """

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
      %Request{arguments: arguments, invoked_with: command, message: message}
    end
  end
end
