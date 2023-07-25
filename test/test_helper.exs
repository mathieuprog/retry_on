{:ok, _} = RetryOn.Repo.start_link()

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(RetryOn.Repo, :manual)
