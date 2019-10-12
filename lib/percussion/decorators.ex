defmodule Percussion.Decorators do
  @moduledoc """
  Built-in command decorators.
  """

  require Logger

  alias Nostrum.Snowflake
  alias Percussion.Request

  @doc """
  Requires the command to be called in a guild.
  """
  @spec guild_only :: Request.step()
  def guild_only do
    fn %Request{message: message} = request ->
      if is_nil(message.guild_id) do
        Request.halt(request, "This command can only be used in guilds.")
      else
        request
      end
    end
  end

  @doc """
  Requires the command to be called in a direct message.
  """
  @spec direct_message_only :: Request.step()
  def direct_message_only do
    fn %Request{message: message} = request ->
      if is_nil(message.guild_id) do
        request
      else
        Request.halt(request, "This command can't be used in guilds.")
      end
    end
  end

  @doc """
  Prevents the command from being called in non-whitelisted guilds.

  Note that it can still be used in DMs.
  """
  @spec whitelist_guilds([Snowflake.t()]) :: Request.step()
  def whitelist_guilds(whitelist) do
    fn %Request{message: message} = request ->
      if is_nil(message.guild_id) or message.guild_id in whitelist do
        request
      else
        Request.halt(request, "This command can't be used in this server.")
      end
    end
  end

  @doc """
  Combines `guild_only/1` and `whitelist_guilds/1`.
  """
  @spec whitelisted_guilds_only([Snowflake.t()]) :: Request.step()
  def whitelisted_guilds_only(whitelist) do
    fn %Request{} = request ->
      request
      |> Request.and_then(guild_only())
      |> Request.and_then(whitelist_guilds(whitelist))
    end
  end

  @doc """
  Prevents the command from being called by non-whitelisted users.
  """
  @spec whitelist_users([Snowflake.t()]) :: Request.step()
  def whitelist_users(whitelist) do
    fn %Request{message: message} = request ->
      if message.author.id in whitelist do
        request
      else
        Request.halt(request, "Permission denied.")
      end
    end
  end

  @doc """
  Measures and stores how long a request took.

  The value is stored in the request's assigns as `response_time`.
  """
  @spec measure_response_time :: Request.step()
  def measure_response_time do
    fn %Request{} = request ->
      start = System.monotonic_time()

      Request.register_after_send(request, fn response ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)

        Request.assign(response, response_time: diff)
      end)
    end
  end

  @doc """
  Logs command requests, and how long they took to complete.
  """
  @spec log_request(Logger.level()) :: Request.step()
  def log_request(level) do
    fn %Request{} = request ->
      request
      |> Request.and_then(&do_log_request(&1, level))
      |> Request.and_then(measure_response_time())
    end
  end

  defp do_log_request(request, level) do
    Logger.log(level, fn ->
      formatted_call(request)
    end)

    Request.register_after_send(request, fn response ->
      Logger.log(level, fn ->
        [formatted_call(request), " in ", formatted_diff(response.assigns.response_time)]
      end)

      response
    end)
  end

  defp formatted_call(request) do
    [request.invoked_with, ?(, Enum.join(request.arguments, ", "), ?)]
  end

  defp formatted_diff(diff) when diff > 1000 do
    [diff |> div(1000) |> Integer.to_string(), "ms"]
  end

  defp formatted_diff(diff) do
    [Integer.to_string(diff), "µs"]
  end
end
