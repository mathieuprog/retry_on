defmodule RetryOn.Repo do
  use Ecto.Repo,
    otp_app: :retry_on,
    adapter: Ecto.Adapters.Postgres
end
