defmodule DbMigrator.Migration do

      alias DbMigratorWeb.SchemaMigration

      @recent_migrations_limit 5

      defimpl Poison.Encoder, for: Tuple do
        def encode(tuple, _options) do
          tuple
          |> Tuple.to_list
          |> Poison.encode!
        end
      end

      @start_apps [
        :mariaex,
        :ecto
      ]

      def repos() do
        Application.get_env(
          Application.get_application(__MODULE__), :ecto_repos, []
        )
      end

      def status() do
        case Cachex.get(:cache, "status") do
          {:ok, true} -> nil
          _ -> Enum.map(repos(), &DbMigrator.Migration.repo_status/1)
        end
      end

      def repo_status(repo, error_msg \\ "") do
        %{
          repo: "#{repo}",
          repoId: repo |> Module.split |> List.last,
          migrated: get_migrated(repo),
          pending: get_pending_migrations(repo),
          error_msg: error_msg
        }
      end

      defp get_migrated(repo) do
        Ecto.Migrator.migrated_versions(repo)
        |> Enum.reverse()
        |> Enum.take(@recent_migrations_limit)
        |> Enum.map(fn (migration) ->
          {:ok, body} = File.read(hd(Path.wildcard("#{migrations_path(repo)}/#{migration}*")))
          {migration, body}
        end)
      end

      defp get_pending_migrations(repo) do
        repo
        |> Ecto.Migrator.migrations(migrations_path(repo))
        |> Enum.reject(fn({state, _, _}) ->
            state == :up
          end)
        |> Enum.reverse()
        |> Enum.map(fn (migration) ->
          {_direction, timestamp, name} = migration
          {:ok, body} = File.read("#{migrations_path(repo)}/#{timestamp}_#{name}.exs")
          {timestamp, body, name}
        end)
      end

      def migrate_to(repo, timestamp, direction, socket) do
        Phoenix.Channel.broadcast! socket, "running", %{running: true}
        Cachex.put(:cache, "status", true, ttl: :timer.seconds(900_000))

        Enum.each(@start_apps, &Application.ensure_all_started/1)
        repo.start_link(pool_size: 1)

        :timer.sleep(5000)

        spawn(fn ->
          try do
            run_migrations_to(repo, timestamp, direction)
            run_seeds_for(repo)
          rescue
            e in Mariaex.Error -> Phoenix.Channel.push socket, "status", DbMigrator.Migration.repo_status(repo, e.mariadb.message)
          end

          Phoenix.Channel.broadcast! socket, "status", DbMigrator.Migration.repo_status(repo)
          Cachex.put(:cache, "status", false)
        end)
      end

      def manual_migrate_to(repo, timestamp, direction, socket) do
        import Ecto.Query, only: [from: 2]

        Enum.each(@start_apps, &Application.ensure_all_started/1)
        repo.start_link(pool_size: 1)

        case direction do
          :up -> repo.insert!(%DbMigratorWeb.SchemaMigration{version: timestamp})
          :down ->
            from(sm in SchemaMigration, where: sm.version == ^timestamp)
            |> repo.delete_all
        end

        Phoenix.Channel.broadcast! socket, "status", DbMigrator.Migration.repo_status(repo)
      end

      def priv_dir(app), do: "#{:code.priv_dir(app)}"

      defp run_migrations_to(repo, timestamp, direction) do
        Ecto.Migrator.run(repo, migrations_path(repo), direction, to: timestamp)
      end

      def run_seeds_for(repo) do
        seed_script = seeds_path(repo)
        if File.exists?(seed_script) do
          Code.eval_file(seed_script)
        end
      end

      def migrations_path(repo), do: priv_path_for(repo, "migrations")

      def seeds_path(repo), do: priv_path_for(repo, "seeds.exs")

      def priv_path_for(repo, filename) do
        app = Keyword.get(repo.config, :otp_app)
        repo_underscore = repo |> Module.split |> List.last |> Macro.underscore
        Path.join([priv_dir(app), repo_underscore, filename])
      end
    end
