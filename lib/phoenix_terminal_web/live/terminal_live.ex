defmodule PhoenixTerminalWeb.TerminalLive do
  use PhoenixTerminalWeb, :live_view

  alias PhoenixTerminal.Terminals
  alias PhoenixTerminal.Sequences

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> update(:output, &format/1)

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
    data = Sequences.escape(data)

    socket
    |> update(:output, &(&1 ++ data))
  end

  defp format(data) do
    {modes, result} =
      Enum.reduce(data, {[], []}, fn
        :reset, {modes, result} -> {[], reset(modes, result)}
        data, {modes, result} -> {modes, [data | result]}
      end)

    result = reset(modes, result)
    Enum.reverse(result)
  end

  defp reset([], result), do: result
  defp reset([_mode | modes], result), do: reset(modes, result)
end
