defmodule Jumubase.Showtime.Participant do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.Showtime.Participant

  schema "participants" do
    field :given_name, :string
    field :family_name, :string
    field :birthdate, Timex.Ecto.Date
    field :phone, :string
    field :email, :string

    timestamps()
  end

  @required_attrs [:given_name, :family_name, :birthdate, :phone, :email]

  @doc false
  def changeset(%Participant{} = participant, attrs) do
    participant
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
