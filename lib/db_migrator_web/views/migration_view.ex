defmodule DbMigratorWeb.MigrationView do
  use DbMigratorWeb, :view

  def get_short_repo_name(repo_name) do
    repo_name |> Module.split |> List.last
  end

  def get_repo_name(%{repo: repo_name}) do
    repo_name
  end

  def get_migrated(%{migrated: migrations}) do
    migrations
  end

  def get_pending(%{pending: migrations}) do
    migrations
  end
end
