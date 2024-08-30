# DbSchemaMigrator

## What Is It?

What is it and where it is used?

DB Schema Migrator is a UI wrapper around [Ecto.Migrator](https://hexdocs.pm/ecto/Ecto.Migrator.html) to manage DB schema migrations and decouple them from main project repos.

Its a tool to manage database migrations like phinx for PHP app or others. The main idea of it is to keep migrations for "dedicated" databases data science or ETL ones. As those databases doesn't have strict "owner" app so its not clear where their migrations should be kept.

So this tool is a try to solve this. It also has UI for easier control over migrations and DB repos.

### Creating a schema migration
#### Create A Migration

* Create a repo config if its missing, described in `Adding Repo To Manage` section of this doc
* Create new migration for desired repo. Make sure to pass repo module name after `-r`, e.g.:
`mix ecto.gen.migration users_table -r DbMigrator.DataRepo`
* Open migration file generate in previous step, eg. `priv/data_repo/migrations/20171108095813_users_table.exs` and add migration code. Refer here for manual https://hexdocs.pm/ecto/Ecto.Migration.html
  ```
  defmodule DbMigrator.DataRepo.Migrations.UsersTable do
    use Ecto.Migration

    def change do
      create table("users") do
        add :group_id, :integer, size: 11
        add :username, :varchar, size: 255
      end
    end
  end
  ```
* Open PR and merge. Tool will deploy automatically and migration appears in `pending` section for this repo

### Migrate/Rollback
Tool UI supports long running migrations using background elixir tasks. So don't worry about long alters or even crashed/closed browse tab.
UI will update itself after migration has been run successfully. Note that there is no possibility to run few migrations in parallel for performance reasons.

#### Migrate
* Click `Migrate` button at the right of migration. Note that all older migrations (all pending migrations below this one if any) will be applied to
* Wait for migration to run and corresponding UI update

#### Rollback
* Click `Rollback` button at the right of migration. Note that all newer migrations (all applied migrations above this one if any) will be rolled back to
* Wait for migration to run and corresponding UI update

### Adding Repo To Manage

#### Adding Repo
* Add repo module. In `lib/repo.ex`:
  ```
  defmodule DbMigrator.DataRepo do
    use Ecto.Repo,
      otp_app: :db_migrator,
      adapter: Ecto.Adapters.MySQL
  end
  ```
* Add repos to `ecto_repos` list. In `config/config.exs`:
  ```
  config :db_migrator,
    ecto_repos: [DbMigrator.RemRepo, DbMigrator.DataRepo]
  ```
* Add repo module to supervision tree. In `lib/db_migrator/application.ex`:
  ```
  children = [
        supervisor(DbMigrator.RemRepo, []),
        supervisor(DbMigrator.DataRepo, []), #This line added

        supervisor(DbMigratorWeb.Endpoint, []),
      ]
  ```
* Define access credentials for desired ENVs. In `config/dev.exs`, `config/prod.exs` etc.:
  ```
  config :db_migrator, DbMigrator.DataRepo,
      username: "data",
      password: "pass",
      database: "data",
      hostname: "127.0.0.1",
      pool_size: 10,
      timeout: :infinity
  ```
* Now you can create migrations for this repo described in `Creating a schema migration` section of this doc

## Running

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).
