defmodule DbMigrator.RemRepo do
  use Ecto.Repo,
    otp_app: :db_migrator,
    adapter: Ecto.Adapters.MySQL
end

defmodule DbMigrator.RemEmailRepo do
  use Ecto.Repo,
    otp_app: :db_migrator,
    adapter: Ecto.Adapters.MySQL
end
