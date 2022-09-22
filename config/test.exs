import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jumubase, JumubaseWeb.Endpoint,
  http: [port: 4001],
  secret_key_base: "gdmnXTTxP5GAW8ta1xHL+uHsHcE1PesiN/qJTNzWG303h/oLR3HFpfFN3JDtG4B9",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Use English locale for tests
config :jumubase, Jumubase.Gettext, default_locale: "en"
config :timex, Timex.Gettext, default_locale: "en"

# Configure your database
config :jumubase, Jumubase.Repo,
  username: "postgres",
  password: "postgres",
  database: "jumubase_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Speed up tests by making hashing faster
config :bcrypt_elixir, log_rounds: 1

# Configure test mailer
config :jumubase, Jumubase.Mailer, adapter: Swoosh.Adapters.Test

# Configure test email
config :jumubase, JumubaseWeb.Email,
  contact_email: "contact@localhost",
  admin_email: "admin@localhost"
