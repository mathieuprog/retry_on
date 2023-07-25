defmodule RetryOnTest do
  use ExUnit.Case

  import RetryOn, only: [retry_on_unique_constraint: 4]

  alias RetryOn.Repo
  alias RetryOn.Wallet
  alias RetryOn.Organization

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RetryOn.Repo)
  end

  defp create_wallet(%Organization{} = organization) do
    wallet_changeset =
      %Wallet{organization_id: organization.id}
      |> Wallet.changeset(%{})

    wallet_changeset =
      if !Repo.exists?(Wallet) do
        Ecto.Changeset.put_change(wallet_changeset, :is_default, true)
      else
        wallet_changeset
      end

    Repo.insert!(wallet_changeset)
  end

  # test "produce error" do
  #   organization = Repo.insert!(%Organization{name: "Acme"})

  #   Enum.each(1..100, fn _ ->
  #     Task.start(fn ->
  #       create_wallet(organization)
  #     end)
  #   end)

  #   Process.sleep(5000)

  #   wallets = Repo.all(Wallet)

  #   assert length(wallets) == 100
  #   assert Enum.count(wallets, &(&1.is_default)) == 1
  # end

  test "retry on unique constraint" do
    organization = Repo.insert!(%Organization{name: "Acme"})

    Enum.each(1..100, fn _ ->
      Task.start(fn ->
        retry_on_unique_constraint(Repo, :organization_id,
          fn _ -> create_wallet(organization) end,
          max_attempts: 10, delay_ms: 100
        )
      end)
    end)

    Process.sleep(5000)

    wallets = Repo.all(Wallet)

    assert length(wallets) == 100
    assert Enum.count(wallets, &(&1.is_default)) == 1
  end
end
