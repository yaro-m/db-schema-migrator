defmodule DbMigratorWeb.SchemaMigration do
    use Ecto.Schema

    schema "schema_migrations" do
      field :version, :integer

      timestamps updated_at: false
    end
  end
