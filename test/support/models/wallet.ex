defmodule RetryOn.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias RetryOn.Wallet

  schema "wallets" do
    field :lock_version, :integer, default: 1
    field :balance_amount, :decimal, default: Decimal.new(0)
    field :is_default, :boolean, default: false
    belongs_to :organization, RetryOn.Organization
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:is_default])
    |> unique_constraint(:organization_id)
  end

  def unset_default_query(organization_id) do
    from(w in Wallet, where: w.organization_id == ^organization_id, update: [set: [is_default: false]])
  end
end
