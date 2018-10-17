defmodule Jumubase.Showtime.Appearance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Appearance, Participant, Performance}

  schema "appearances" do
    field :instrument, :string
    field :role, :string
    field :age_group, :string
    field :points, :integer

    belongs_to :performance, Performance
    belongs_to :participant, Participant, on_replace: :delete

    timestamps()
  end

  @required_attrs [:role, :instrument]

  @doc false
  def changeset(%Appearance{} = appearance, attrs) do
    appearance
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:role, JumuParams.participant_roles)
    |> cast_assoc(:participant, required: true)
    |> preserve_participant_identity
  end

  def is_soloist(%Appearance{role: role}), do: role == "soloist"

  def is_ensemblist(%Appearance{role: role}), do: role == "ensemblist"

  def is_accompanist(%Appearance{role: role}), do: role == "accompanist"

  # Private helpers

  # Preserves the participant's identity when updating a nested participant.
  defp preserve_participant_identity(%Changeset{
    changes: %{participant: %{action: :update} = pt_cs}
  } = changeset) do
    put_change(changeset, :participant, Participant.preserve_identity(pt_cs))
  end
  defp preserve_participant_identity(%Changeset{} = changeset), do: changeset
end
