defmodule PhoenixTerminal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixTerminalWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_terminal, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixTerminal.PubSub},
      # Start a worker by calling: PhoenixTerminal.Worker.start_link(arg)
      # {PhoenixTerminal.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixTerminalWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixTerminal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixTerminalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
