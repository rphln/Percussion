defmodule Percussion.Adapter.Nostrum do
  @moduledoc """
  Utility functions that don't warrant their own modules, but are likely useful for most
  bots.
  """

  alias Nostrum.Api
  alias Nostrum.Struct.Message

  alias Percussion.Request

  @doc """
  Creates a `t:Percussion.Request.t/0` from a `t:Nostrum.Struct.Message.t/0`.
  """
  @spec to_request(Message.t(), String.t()) :: {:ok, Request.t()} | :error
  def to_request(%Message{content: content} = message, prefix) do
    with {:ok, content} <- take_prefix(content, prefix) do
      [invoked_with | arguments] = String.split(content, ~r/\s/u, parts: 2)

      arguments =
        case arguments do
          [] -> []
          [arguments] -> quote_aware_split(arguments)
        end

      request = %Request{
        arguments: arguments,
        author_id: message.author.id,
        channel_id: message.channel_id,
        guild_id: message.guild_id,
        invoked_with: invoked_with,
        message: message,
        message_id: message.id
      }

      {:ok, request}
    end
  end

  defp take_prefix(string, prefix) do
    if String.starts_with?(string, prefix) do
      {:ok, String.replace_prefix(string, prefix, "")}
    else
      :error
    end
  end

  defp quote_aware_split(text) do
    OptionParser.split(text)
  rescue
    _ in RuntimeError -> String.split(text)
  end

  @doc """
  Replies a request to the respective channel.
  """
  @spec create_message!(Request.t()) :: Request.t()
  def create_message!(%Request{message: message, assigns: assigns} = request) do
    opts = Map.take(assigns, [:content, :embed, :file])

    response =
      unless Enum.empty?(opts) do
        Api.create_message!(message, opts)
      end

    request
    |> Request.assign(response: response)
    |> Request.execute_after_send()
  end
end
