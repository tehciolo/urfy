defmodule Urfy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UrfyWeb.Telemetry,
      Urfy.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:urfy, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:urfy, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Urfy.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Urfy.Finch},
      # Start a worker by calling: Urfy.Worker.start_link(arg)
      # {Urfy.Worker, arg},
      # Start to serve requests, typically the last entry
      UrfyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Urfy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UrfyWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
