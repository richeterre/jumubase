defmodule Jumubase.Foundation.Stage do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Jumubase.Foundation.{Host, Stage}
  alias Jumubase.Showtime.Performance

  schema "stages" do
    field :name, :string
    field :latitude, :float
    field :longitude, :float

    belongs_to :host, Host
    has_many :performances, Performance

    timestamps()
  end

  @required_attrs [:name]
  @optional_attrs [:latitude, :longitude]

  @doc false
  def changeset(%Stage{} = stage, attrs) do
    stage
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_coordinates()
  end

  defp validate_coordinates(changeset) do
    latitude = get_field(changeset, :latitude)
    longitude = get_field(changeset, :longitude)

    cond do
      (!latitude and !!longitude) or (!!latitude and !longitude) ->
        changeset
        |> add_error(
          :base,
          dgettext("errors", "must have either have complete coordinates or empty ones")
        )

      true ->
        changeset
    end
  end
end
