defmodule Jumubase.Showtime.Piece do
  use Ecto.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Performance, Piece}

  schema "pieces" do
    field :composer_born, :string
    field :composer_died, :string
    field :composer, :string
    field :artist, :string
    field :epoch, :string
    field :minutes, :integer
    field :seconds, :integer
    field :title, :string

    belongs_to :performance, Performance

    timestamps()
  end

  @required_attrs [:title, :epoch, :minutes, :seconds]

  @optional_attrs [:composer, :composer_born, :composer_died, :artist]

  @doc false
  def changeset(%Piece{} = piece, attrs) do
    piece
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_person # composer or artist
    |> validate_inclusion(:epoch, JumuParams.epochs)
    |> validate_inclusion(:minutes, 0..59)
    |> validate_inclusion(:seconds, 0..59)
    |> clean_up_person_fields
  end

  # Private helpers

  # Validates the changeset's person (composer or artist) data.
  defp validate_person(%Changeset{} = changeset) do
    composer = get_field(changeset, :composer)
    artist = get_field(changeset, :artist)

    cond do
      !composer and !artist or !!composer and !!artist ->
        add_error(changeset, :base,
          dgettext("errors", "must have a composer or artist")
        )
      !!composer ->
        validate_required(changeset, :composer_born)
      true ->
        changeset
    end
  end

  # Removes composer data when setting artist, and vice versa.
  defp clean_up_person_fields(
    %Changeset{changes: %{artist: artist}} = changeset
  ) when not is_nil(artist) do
    changeset
    |> put_change(:composer, nil)
    |> put_change(:composer_born, nil)
    |> put_change(:composer_died, nil)
  end
  defp clean_up_person_fields(
    %Changeset{changes: %{composer: composer}} = changeset
  ) when not is_nil(composer) do
    put_change(changeset, :artist, nil)
  end
  defp clean_up_person_fields(changeset), do: changeset
end
