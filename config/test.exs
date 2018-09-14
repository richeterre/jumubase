use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jumubase, JumubaseWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :phauxth,
  token_salt: String.duplicate("x", 8),
  log_level: :error

# Configure your database
config :jumubase, Jumubase.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "jumubase_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Speed up tests by making hashing faster
config :bcrypt_elixir, log_rounds: 4

# Configure test mailer
config :jumubase, Jumubase.Mailer,
  adapter: Bamboo.TestAdapter
