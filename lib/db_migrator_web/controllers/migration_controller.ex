defmodule DbMigratorWeb.MigrationController do
  use DbMigratorWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:status, DbMigrator.Migration.status())
    |> render("index.html")
  end
end
