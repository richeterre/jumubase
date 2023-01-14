# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :jumubase,
  ecto_repos: [Jumubase.Repo]

# Set default locale
locale = "de"
config :jumubase, Jumubase.Gettext, default_locale: locale
config :timex, default_locale: locale
config :timex, Timex.Gettext, default_locale: locale

# Configure the endpoint
config :jumubase, JumubaseWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: JumubaseWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Jumubase.PubSub,
  live_view: [signing_salt: "4+PLR3SMvBIBZG4im48JLB2wWM+2prRB"]

# Keep microsecond precision in timestamps
config :jumubase, Jumubase.Repo, migration_timestamps: [type: :naive_datetime_usec]

config :dart_sass,
  version: "1.54.8",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

config :jumubase, ChromicPDF, on_demand: false

# Configure generic email addresses (should be overriden in runtime.exs for :prod)
config :jumubase, JumubaseWeb.Email,
  default_sender: {"Jumu weltweit", "no-reply@localhost"},
  contact_email: "contact@localhost",
  admin_email: "admin@localhost"

# Configure certificates (should be overriden in runtime.exs for :prod)
config :jumubase, :certificates, template_url: "#"

# Configure Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
