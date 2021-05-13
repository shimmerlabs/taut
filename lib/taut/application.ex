defmodule Taut.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Taut.Repo,
      # Start the Telemetry supervisor
      TautWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Taut.PubSub},
      # Start a worker by calling: Taut.Worker.start_link(arg)
      # {Taut.Worker, arg}
    ]

    # Start the Endpoint (http/https) unless we've set server: false
    run_server = Application.get_env(:taut, :server, true)
    children = children ++ if(run_server, do: [TautWeb.Endpoint], else: [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Taut.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TautWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
