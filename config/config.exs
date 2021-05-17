# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :taut,
  ecto_repos: [Taut.Repo],
  generators: [binary_id: true]

config :taut, Taut.Repo,
  migration_primary_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :taut, TautWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Olkci+IaggBH1RuZL517vp/36VgpH6H/mGwSxHsXt6fUpcMNQUEVss2UPh8Sf5ZT",
  render_errors: [view: TautWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Taut.PubSub,
  live_view: [signing_salt: "trRUdoe/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
