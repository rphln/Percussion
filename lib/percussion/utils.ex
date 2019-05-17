defmodule Percussion.Utils do
  @moduledoc """
  Utility functions that don't warrant their own modules.
  """

  def split(text) do
    OptionParser.split(text)
  rescue
    _ in RuntimeError -> String.split(text)
  end
end
