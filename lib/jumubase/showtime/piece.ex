defmodule Jumubase.Showtime.Piece do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Performance, Piece}

  schema "pieces" do
    field :title, :string
    field :composer_born, :string
    field :composer_died, :string
    field :composer, :string
    field :artist, :string
    field :epoch, :string
    field :minutes, :integer
    field :seconds, :integer

    belongs_to :performance, Performance

    timestamps()
  end

  @required_attrs [:title, :minutes, :seconds]

  @optional_attrs [:composer, :composer_born, :composer_died, :artist, :epoch]

  @doc false
  def changeset(%Piece{} = piece, attrs) do
    piece
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_length(:title, max: 255)
    |> validate_person
    |> validate_inclusion(:epoch, JumuParams.epochs())
    |> validate_inclusion(:minutes, 0..59)
    |> validate_inclusion(:seconds, 0..59)
    |> clean_up_fields
  end

  @doc """
  Allows migrating the piece by preserving only its "timeless" data.
  """
  def migration_changeset(%Piece{} = piece) do
    attrs = piece |> Map.take(@required_attrs ++ @optional_attrs)
    Changeset.change(%Piece{}, attrs)
  end

  # Private helpers

  # Validates the changeset's person (composer or artist) data.
  defp validate_person(%Changeset{} = changeset) do
    epoch = get_field(changeset, :epoch)
    composer = get_field(changeset, :composer)
    artist = get_field(changeset, :artist)

    cond do
      epoch == "trad" ->
        changeset

      !composer and !artist ->
        changeset
        |> add_error(:artist, dgettext("errors", "can't be blank"))
        |> add_error(:composer, dgettext("errors", "can't be blank"))

      !!composer and !!artist ->
        add_error(
          changeset,
          :base,
          dgettext("errors", "can only have either a composer or an artist")
        )

      !!composer ->
        validate_required(changeset, :composer_born)

      true ->
        changeset
    end
  end

  defp clean_up_fields(%Changeset{} = changeset) do
    changeset
    |> trim_fields([:title, :composer, :composer_born, :composer_died, :artist])
    |> clean_up_person_fields
  end

  # Removes whitespace around changes in the given fields.
  defp trim_fields(%Changeset{} = changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      update_change(cs, field, fn
        val when is_binary(val) -> String.trim(val)
        val -> val
      end)
    end)
  end

  # Clears obsolete composer/artist fields depending on incoming changes.
  defp clean_up_person_fields(%Changeset{changes: %{epoch: "trad"}} = changeset) do
    changeset
    |> clear_composer_fields()
    |> clear_artist_fields()
  end

  defp clean_up_person_fields(%Changeset{changes: %{artist: artist}} = changeset)
       when not is_nil(artist) do
    clear_composer_fields(changeset)
  end

  defp clean_up_person_fields(%Changeset{changes: %{composer: composer}} = changeset)
       when not is_nil(composer) do
    clear_artist_fields(changeset)
  end

  defp clean_up_person_fields(changeset), do: changeset

  defp clear_composer_fields(%Changeset{} = changeset) do
    changeset
    |> put_change(:composer, nil)
    |> put_change(:composer_born, nil)
    |> put_change(:composer_died, nil)
  end

  defp clear_artist_fields(%Changeset{} = changeset) do
    put_change(changeset, :artist, nil)
  end
end
