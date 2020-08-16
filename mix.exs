defmodule Jumubase.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jumubase,
      version: "1.0.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Jumubase.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "1.5.2"},
      {:absinthe_plug, "1.5.0"},
      {:bamboo, "~> 1.1"},
      {:bcrypt_elixir, "~> 1.0"},
      {:dataloader, "1.0.6"},
      {:earmark, "~> 1.2"},
      {:ecto_sql, "3.4.5"},
      {:ex_machina, "~> 2.2"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.1"},
      {:nimble_csv, "~> 0.6"},
      {:pdf_generator, "~> 0.4"},
      {:phauxth, "~> 1.2"},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_live_view, "~> 0.14.4"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 7.0"},
      {:sneeze, "~> 1.1"},
      {:timex, "~> 3.0"},
      {:xml_builder, "~> 2.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      {:"ecto.setup", ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"]},
      {:"ecto.reset", ["ecto.drop", "ecto.setup"]},
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
