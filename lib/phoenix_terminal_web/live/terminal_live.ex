defmodule PhoenixTerminalWeb.TerminalLive do
  use PhoenixTerminalWeb, :live_view

  require Logger

  alias PhoenixTerminal.Terminals
  alias PhoenixTerminal.Sequences

  @impl true
  def render(assigns) do
    ~H"""
    <code class="font-mono w-[80ch] h-[80ch] flex flex-col justify-start items-start bg-black text-white">
      <span :for={y <- 0..79} class="flex flex-row justify-start items-baseline">
        <.output :for={x <- 0..79} value={@output[{x, y}]} cursor={{x, y} == @cursor} />
      </span>
    </code>
    """
  end

  attr :value, :string, required: true
  attr :cursor, :boolean, default: false

  defp output(assigns) do
    assigns =
      assigns
      |> update(:cursor, fn
        true -> "bg-white text-black"
        false -> ""
      end)

    ~H"""
    <span class={["w-[1ch] h-[1ch]", @cursor]}>{@value}</span>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, term} = Terminals.start()

    socket =
      socket
      |> assign(:term, term)
      |> assign(:cursor, {0, 0})
      |> assign(:output, %{})

    {:ok, socket}
  end

  @impl true
  def handle_info({:stdout, _ospid, data}, socket) do
    socket =
      socket
      |> write_output(data)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:stderr, _ospid, data}, socket) do
    socket =
      socket
      |> write_output(data)

    {:noreply, socket}
  end

  defp write_output(socket, data)

  defp write_output(socket, <<>>), do: socket

  defp write_output(socket, <<"\e[", data::binary>>) do
    case String.split(data, "m", parts: 2) do
      [_, data] -> write_output(socket, data)
      [_] -> socket
      [] -> socket
    end
  end

  defp write_output(socket, <<"\n", data::binary>>) do
    socket =
      socket
      |> update(:cursor, fn {_, y} -> {0, y + 1} end)

    write_output(socket, data)
  end

  defp write_output(socket, <<"\r", data::binary>>) do
    socket =
      socket
      |> update(:cursor, fn {_, y} -> {0, y} end)

    write_output(socket, data)
  end

  defp write_output(socket, <<c::binary-1, data::binary>>) do
    if String.printable?(c) do
      socket =
        socket
        |> update(:output, &Map.put(&1, socket.assigns.cursor, c))
        |> update(:cursor, fn
          {x, y} when x >= 79 -> {0, y + 1}
          {x, y} -> {x + 1, y}
        end)

      write_output(socket, data)
    else
      <<c>> = c
      Logger.debug("unhandled unprintable ASCII: 0x#{Integer.to_string(c, 16)}")
      write_output(socket, data)
    end
  end
end
