use Mix.Config

config :db_migrator, DbMigrator.DbRepo,
  username: "root",
  password: "",
  database: "db",
  hostname: "127.0.0.1",
  pool_size: 10,
  timeout: :infinity
