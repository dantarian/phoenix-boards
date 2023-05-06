defmodule PhoenixBoards.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhoenixBoardsWeb.Telemetry,
      # Start the Ecto repository
      PhoenixBoards.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixBoards.PubSub},
      # Start Finch
      {Finch, name: PhoenixBoards.Finch},
      # Start the Endpoint (http/https)
      PhoenixBoardsWeb.Endpoint
      # Start a worker by calling: PhoenixBoards.Worker.start_link(arg)
      # {PhoenixBoards.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixBoards.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixBoardsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
