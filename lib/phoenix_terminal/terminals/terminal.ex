defmodule PhoenixTerminal.Terminals.Terminal do
  use GenServer

  require Logger

  alias PhoenixTerminal.Terminals

  def start_link(state) when is_map(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def start(opts) when is_list(opts) do
    opts = Keyword.validate!(opts, owner: self())
    Terminals.Supervisor.start_child({__MODULE__, Map.new(opts)})
  end

  @impl true
  def init(state) do
    mref = Process.monitor(state.owner)

    state =
      state
      |> Map.put(:mref, mref)
      |> start_term()

    {:ok, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, pid, reason}, %{mref: ref, owner: pid} = state) do
    Logger.debug("terminal owner #{inspect(pid)} exited with reason #{inspect(reason)}")

    :ok = :exec.stop(state.pid)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:DOWN, ospid, :process, pid, reason}, %{pid: pid, ospid: ospid} = state) do
    Logger.debug("terminal process #{inspect(ospid)} exited with reason #{inspect(reason)}")

    if reason != :normal do
      send(state.owner, {:term_exit, reason})
    end

    state = start_term(state)
    {:noreply, state}
  end

  defp start_term(state) do
    {:ok, pid, ospid} =
      :exec.run_link("zsh --login", [
        :pty,
        :monitor,
        :stdin,
        stdout: state.owner,
        stderr: state.owner,
        winsz: {24, 80}
      ])

    state
    |> Map.put(:pid, pid)
    |> Map.put(:ospid, ospid)
  end
end
