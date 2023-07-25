import Config

config :logger, level: :warn # set to :debug to view SQL queries in logs

config :retry_on,
  ecto_repos: [RetryOn.Repo]

config :retry_on, RetryOn.Repo,
  username: "postgres",
  password: "postgres",
  database: "retry_on_test",
  hostname: "localhost",
  port: 5434,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support"
