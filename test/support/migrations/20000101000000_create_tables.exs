defmodule RetryOn.CreateTables do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
    end

    create table(:wallets) do
      add :lock_version, :integer, default: 1
      add :balance_amount, :numeric, null: false, default: 0
      add :is_default, :boolean, null: false, default: false

      add :organization_id, references(:organizations, on_delete: :delete_all), null: true
    end

    create unique_index(:wallets, [:organization_id], where: "is_default = true")
  end
end
