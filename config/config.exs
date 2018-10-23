# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :jumubase,
  ecto_repos: [Jumubase.Repo]

# Set default locale
config :jumubase, Jumubase.Gettext, default_locale: "de"
config :timex, Timex.Gettext, default_locale: "de"

# Configure the endpoint
config :jumubase, JumubaseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CItDuu3F0bThL/GnGj6lG4CNhFF/JPz/LHyWFVkLRdht2gpHfuFftGiO1paelppz",
  render_errors: [view: JumubaseWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Jumubase.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure Phauxth authentication
config :phauxth,
  endpoint: JumubaseWeb.Endpoint,
  user_messages: Jumubase.Accounts.UserMessages

# Configure mailer
config :jumubase, Jumubase.Mailer,
  adapter: Bamboo.LocalAdapter

# Configure Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
