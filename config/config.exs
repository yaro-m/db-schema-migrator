use Mix.Config

# General application configuration
config :db_migrator,
  ecto_repos: []

# Configures the endpoint
config :db_migrator, DbMigratorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xxxxx",
  render_errors: [view: DbMigratorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DbMigrator.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
