use Mix.Config

config :db_migrator, DbMigratorWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :db_migrator, DbMigrator.Repo,
  username: "postgres",
  password: "postgres",
  database: "db_migrator_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
