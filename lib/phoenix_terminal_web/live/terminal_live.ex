defmodule PhoenixTerminalWeb.TerminalLive do
  use PhoenixTerminalWeb, :live_view

  alias PhoenixTerminal.Terminals

  @impl true
  def render(assigns) do
    ~H"""
    <pre class="font-mono w-[80ch] whitespace-pre-wrap break-all">
      {@output}
    </pre>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, term} = Terminals.start()

    socket =
      socket
      |> assign(:term, term)
      |> assign(:output, [])

    {:ok, socket}
  end

  @impl true
  def handle_info({:stdout, _ospid, data}, socket) do
    socket =
      socket
      |> append_output(data)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:stderr, _ospid, data}, socket) do
    socket =
      socket
      |> append_output(data)

    {:noreply, socket}
  end

  defp append_output(socket, data) do
    socket
    |> update(:output, &[&1, data])
  end
end
