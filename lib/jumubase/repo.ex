defmodule Jumubase.Repo do
  use Ecto.Repo,
    otp_app: :jumubase,
    adapter: Ecto.Adapters.Postgres
end
