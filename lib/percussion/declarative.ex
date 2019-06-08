defmodule Percussion.Declarative do
  @moduledoc """
  Delegates to the router components.
  """

  defdelegate command(name, dispatch, opts \\ []),
    to: Percussion.Declarative.Command,
    as: :new

  defdelegate router(entries),
    to: Percussion.Declarative.Router,
    as: :new

  defdelegate plug(child, pipes),
    to: Percussion.Declarative.Pipe,
    as: :new

  defdelegate execute(root, request),
    to: Percussion.Declarative.Dispatcher,
    as: :execute
end
