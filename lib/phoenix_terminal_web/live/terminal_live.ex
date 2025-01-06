defmodule PhoenixTerminalWeb.TerminalLive do
  use PhoenixTerminalWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    This is a test.
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
