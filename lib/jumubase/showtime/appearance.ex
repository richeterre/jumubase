defmodule Jumubase.Showtime.Appearance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Appearance, Participant, Performance}

  schema "appearances" do
    field :instrument, :string
    field :participant_role, :string
    field :points, :integer

    belongs_to :performance, Performance
    belongs_to :participant, Participant

    timestamps()
  end

  @required_attrs [:performance_id, :participant_role, :instrument]

  @doc false
  def changeset(%Appearance{} = appearance, attrs) do
    appearance
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> cast_assoc(:participant, required: true)
    |> validate_inclusion(:participant_role, JumuParams.participant_roles)
  end
end
