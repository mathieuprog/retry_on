defmodule RetryOn do
  defdelegate retry_on_stale(fun, opts), to: RetryOnStale

  def retry_on_unique_constraint(repo, field, fun, opts) do
    max_attempts = Keyword.fetch!(opts, :max_attempts)
    delay_ms = Keyword.fetch!(opts, :delay_ms)

    if repo.in_transaction?() do
      raise """
      `retry_on_unique_constraint/3` cannot be called within a transaction as it includes a retry operation
      after a transaction failure. Continuing with a failed transaction is not permitted.
      """
    end

    do_retry_on_unique_constraint(field, fun, max_attempts, delay_ms, 1)
  end

  defp do_retry_on_unique_constraint(field, fun, max_attempts, delay_ms, attempt) do
    try do
      case fun.(attempt) do
        {:error, %Ecto.Changeset{} = changeset} ->
          if ChangesetHelpers.field_violates_constraint?(changeset, field, :unique) do
            :timer.sleep(delay_ms)
            do_retry_on_unique_constraint(field, fun, max_attempts, delay_ms, attempt + 1)
          end

        value ->
          value
      end
    rescue
      e in Ecto.InvalidChangesetError ->
        if(
          attempt < max_attempts
          and ChangesetHelpers.field_violates_constraint?(e.changeset, field, :unique)
        ) do
          :timer.sleep(delay_ms)
          do_retry_on_unique_constraint(field, fun, max_attempts, delay_ms, attempt + 1)
        else
          reraise e, __STACKTRACE__
        end
    end
  end
end
