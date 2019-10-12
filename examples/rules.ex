defmodule Example.Commands.Ping do
  @moduledoc """
  Does something.

  By default, this attribute will be used as the command help; you can override it by
  defining your own `help/0`.
  """

  use Percussion, :command

  def aliases do
    ["ping"]
  end

  def pipeline do
    [whitelist_guilds([123_456_789, 987_654_321])]
  end

  def handle(_request) do
    """
    Pong!
    """
  end
end
