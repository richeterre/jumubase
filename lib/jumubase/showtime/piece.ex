defmodule Jumubase.Showtime.Piece do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Performance, Piece}

  schema "pieces" do
    field :composer_born, :string
    field :composer_died, :string
    field :composer_name, :string
    field :epoch, :string
    field :minutes, :integer
    field :seconds, :integer
    field :title, :string

    belongs_to :performance, Performance

    timestamps()
  end

  @required_attrs [:title, :composer_name, :composer_born, :epoch, :minutes, :seconds]

  @optional_attrs [:composer_died]

  @doc false
  def changeset(%Piece{} = piece, attrs) do
    piece
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:epoch, JumuParams.epochs)
    |> validate_inclusion(:minutes, 0..59)
    |> validate_inclusion(:seconds, 0..59)
  end
end
