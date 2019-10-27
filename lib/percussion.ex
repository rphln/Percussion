defmodule Percussion do
  @moduledoc """
  Provides templates for common patterns among bots.
  """

  @doc """
  When used, applies the specified template.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  @doc """
  Defaults for modules that implement `Percussion.Command`.
  """
  def command do
    quote do
      @behaviour Percussion.Command

      alias Percussion.Request

      import Percussion.Decorators
      import Percussion.Request
    end
  end
end
