defmodule PhoenixTerminal.Terminals do
  alias __MODULE__

  defdelegate child_spec(spec), to: Terminals.Supervisor

  def start(opts \\ []) when is_list(opts) do
    Terminals.Terminal.start(opts)
  end
end
