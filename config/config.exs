# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :jumubase,
  ecto_repos: [Jumubase.Repo]

# API keys
config :jumubase, JumubaseWeb.MapHelpers, google_api_key: System.get_env("GOOGLE_API_KEY")

config :jumubase, JumubaseWeb.Api.Auth, api_key: System.get_env("JUMU_API_KEY")

# Companion app IDs

config :jumubase, :app_ids,
  android: System.get_env("JUMU_APP_ID_ANDROID"),
  ios: System.get_env("JUMU_APP_ID_IOS")

# Set default locale
locale = "de"
config :jumubase, Jumubase.Gettext, default_locale: locale
config :timex, default_locale: locale
config :timex, Timex.Gettext, default_locale: locale

# Configure the endpoint
config :jumubase, JumubaseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CItDuu3F0bThL/GnGj6lG4CNhFF/JPz/LHyWFVkLRdht2gpHfuFftGiO1paelppz",
  render_errors: [view: JumubaseWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Jumubase.PubSub,
  live_view: [signing_salt: "4+PLR3SMvBIBZG4im48JLB2wWM+2prRB"]

# Keep microsecond precision in timestamps
config :jumubase, Jumubase.Repo, migration_timestamps: [type: :naive_datetime_usec]

# Configure mailer
config :jumubase, Jumubase.Mailer, adapter: Bamboo.LocalAdapter

# Configure email
config :jumubase, JumubaseWeb.Email,
  default_sender: {"Jumu weltweit", "no-reply@jumu-weltweit.org"},
  contact_email: System.get_env("JUMU_CONTACT_EMAIL"),
  admin_email: System.get_env("JUMU_ADMIN_EMAIL")

# Configure release level
config :jumubase, release_level: System.get_env("RELEASE_LEVEL")

# Configure Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Sentry
config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  filter: Jumubase.SentryEventFilter,
  included_environments: ~w(staging production),
  environment_name: System.get_env("RELEASE_LEVEL") || "development"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
