defmodule Jumubase.Foundation.Stage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.Foundation.{Host, Stage}
  alias Jumubase.Showtime.Performance

  schema "stages" do
    field :name, :string

    belongs_to :host, Host
    has_many :performances, Performance

    timestamps()
  end

  @required_attrs [:name]

  @doc false
  def changeset(%Stage{} = stage, attrs) do
    stage
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
