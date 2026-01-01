defmodule LinuxConfig.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LinuxConfigWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:linux_config, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LinuxConfig.PubSub},
      # Start a worker by calling: LinuxConfig.Worker.start_link(arg)
      # {LinuxConfig.Worker, arg},
      # Start to serve requests, typically the last entry
      LinuxConfigWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LinuxConfig.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LinuxConfigWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
