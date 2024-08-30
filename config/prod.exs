use Mix.Config

config :db_migrator, DbMigratorWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  root: "."

config :logger, level: :info

config :db_migrator, DbMigratorWeb.Endpoint,
  secret_key_base: "xxxxx"
