# RetryOn

## `retry_on_stale/2`

`retry_on_stale/2` performs an operation that might raise an `Ecto.StaleEntryError` error and retries
it a specified number of times with a delay between each attempt.

## Example

The example features a wallet's `balance_amount`, protected by [optimistic locking](https://hexdocs.pm/ecto/Ecto.Changeset.html#optimistic_lock/3) to prevent race conditions. The `retry_on_stale/2` function handles `Ecto.StaleEntryError` from concurrent transactions, refetching the wallet and retrying the operation.

```elixir
import RetryOn, only: [retry_on_stale: 2]

def increase_wallet_balance(%Wallet{} = wallet, amount) do
  retry_on_stale(
    fn attempt ->
      # refetch the latest wallet data for subsequent attempts
      wallet = if attempt == 1, do: wallet, else: Repo.get!(Wallet, wallet.id)

      # this function could raise a StaleEntryError
      do_increase_wallet_balance(wallet, amount)
    end,
    max_attempts: 5, delay_ms: 100
  )
end

defp do_increase_wallet_balance(%Wallet{} = wallet, amount) do
  new_balance = Decimal.add(wallet.balance_amount, amount)

  wallet
  |> Ecto.Changeset.change(balance_amount: new_balance)
  |> Ecto.Changeset.optimistic_lock(:lock_version)
  |> Repo.update!()
end
```

## Options

`:max_attempts` - The maximum number of attempts to perform the operation
before giving up and re-raising the last `Ecto.StaleEntryError`.

`:delay_ms` - The delay in milliseconds between each attempt.

## `retry_on_unique_constraint/3`

`retry_on_unique_constraint/3` performs an operation that might raise an `Ecto.UniqueConstraintError` error and retries
it a specified number of times with a delay between each attempt.

## Example

```elixir
import RetryOn, only: [retry_on_unique_constraint: 2]

retry_on_unique_constraint(
  Repo,
  :my_field,
  fn _ ->
    # Code that performs an operation which may result in a unique constraint error on `:my_field`.
    # The function is retried if a unique constraint error is found in a `{:error, changeset}` tuple or
    # an `%Ecto.InvalidChangesetError{changeset: changeset}` error.
  end,
  max_attempts: 2, delay_ms: 500
)
```

## Options

`:max_attempts` - The maximum number of attempts to perform the operation
before giving up and re-raising the last Ecto.StaleEntryError.

`:delay_ms` - The delay in milliseconds between each attempt.

## Installation

Add `retry_on` for Elixir as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:retry_on, "~> 0.1.0"}
  ]
end
```

## HexDocs

HexDocs documentation can be found at [https://hexdocs.pm/retry_on](https://hexdocs.pm/retry_on).
