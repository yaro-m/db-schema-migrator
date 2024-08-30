defmodule DbMigratorWeb.MigrationsChannel do
    use Phoenix.Channel

    def join("migrations", _message, socket) do
      {:ok, socket}
    end

    def handle_in("migration", %{"status" => "get"}, socket) do
      {:ok, status} = Cachex.get(:cache, "status")
      Phoenix.Channel.broadcast! socket, "running", %{running: status}
      {:noreply, socket}
    end
    def handle_in("migration", %{"migration" => "migrate", "repo" => repo, "timestamp" => timestamp}, socket) do
      DbMigrator.Migration.migrate_to(
        String.to_atom(repo), timestamp, :up,
        socket
      )
      {:noreply, socket}
    end
    def handle_in("migration", %{"migration" => "rollback", "repo" => repo, "timestamp" => timestamp}, socket) do
      DbMigrator.Migration.migrate_to(
        String.to_atom(repo), timestamp, :down,
        socket
      )
      {:noreply, socket}
    end
    def handle_in("migration", %{"migration" => "manual_migrate", "repo" => repo, "timestamp" => timestamp}, socket) do
      DbMigrator.Migration.manual_migrate_to(
        String.to_atom(repo), timestamp, :up,
        socket
      )
      {:noreply, socket}
    end
    def handle_in("migration", %{"migration" => "manual_rollback", "repo" => repo, "timestamp" => timestamp}, socket) do
      DbMigrator.Migration.manual_migrate_to(
        String.to_atom(repo), timestamp, :down,
        socket
      )
      {:noreply, socket}
    end
  end
