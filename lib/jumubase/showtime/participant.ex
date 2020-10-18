defmodule Jumubase.Showtime.Participant do
  use Jumubase.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Jumubase.Utils
  alias Jumubase.Showtime.{Appearance, Participant}

  schema "participants" do
    field :given_name, :string
    field :family_name, :string
    field :birthdate, :date
    field :phone, :string
    field :email, :string

    has_many :appearances, Appearance
    has_many :performances, through: [:appearances, :performance]

    timestamps()
  end

  @identity_attrs [:given_name, :family_name, :birthdate]
  @required_attrs @identity_attrs ++ [:phone, :email]

  @doc false
  def changeset(%Participant{} = participant, attrs) do
    participant
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, Utils.email_format())
    |> sanitize_text_input
  end

  @doc """
  Returns whether the changeset has any changes to fields that
  might alter the participant's identity, such as name or birthdate.
  """
  def has_identity_changes?(%Changeset{changes: changes}) do
    Enum.any?(@identity_attrs, &Map.has_key?(changes, &1))
  end

  def has_identity_changes?(_), do: false

  # Private helpers

  defp sanitize_text_input(%Changeset{} = changeset) do
    changeset
    |> update_change(:given_name, &String.trim/1)
    |> update_change(:family_name, &String.trim/1)
    |> update_change(:phone, &String.trim/1)
    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
  end
end
