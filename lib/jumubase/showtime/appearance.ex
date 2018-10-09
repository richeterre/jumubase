defmodule Jumubase.Showtime.Appearance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jumubase.JumuParams
  alias Jumubase.Showtime.{Appearance, Participant, Performance}

  schema "appearances" do
    field :instrument, :string
    field :role, :string
    field :age_group, :string
    field :points, :integer

    belongs_to :performance, Performance
    belongs_to :participant, Participant

    timestamps()
  end

  @required_attrs [:role, :instrument]

  @doc false
  def changeset(%Appearance{} = appearance, attrs) do
    appearance
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> cast_assoc(:participant, required: true)
    |> validate_inclusion(:role, JumuParams.participant_roles)
  end

  def is_soloist(%Appearance{} = a), do: has_role(a, "soloist")

  def is_ensemblist(%Appearance{} = a), do: has_role(a, "ensemblist")

  def is_accompanist(%Appearance{} = a), do: has_role(a, "accompanist")

  # Private helpers

  defp has_role(%Appearance{role: role}, given_role) do
    role == given_role
  end
end
