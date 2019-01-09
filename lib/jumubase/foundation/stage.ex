defmodule Jumubase.Foundation.Stage do
  use Ecto.Schema
  alias Jumubase.Foundation.Host
  alias Jumubase.Showtime.Performance

  schema "stages" do
    field :name, :string

    belongs_to :host, Host
    has_many :performances, Performance

    timestamps()
  end
end
