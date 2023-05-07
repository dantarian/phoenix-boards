# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phoenix_boards,
  ecto_repos: [PhoenixBoards.Repo]

# Configures the endpoint
config :phoenix_boards, PhoenixBoardsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: PhoenixBoardsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixBoards.PubSub,
  live_view: [signing_salt: "BrE0Psq3"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :phoenix_boards, PhoenixBoards.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_boards, :pow,
  user: PhoenixBoards.Users.User,
  repo: PhoenixBoards.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
