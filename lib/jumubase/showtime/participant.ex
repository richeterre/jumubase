defmodule Jumubase.Showtime.Participant do
  use Jumubase.Schema
  import Ecto.Changeset
  import Jumubase.Gettext
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
  Invalidates the changeset if the changes affect the participant's identity.
  """
  def preserve_identity(%Changeset{changes: changes} = changeset) do
    case Enum.filter(@identity_attrs, &Map.has_key?(changes, &1)) do
      [] ->
        changeset

      changed_fields ->
        Enum.reduce(changed_fields, changeset, fn field, cs ->
          add_error(cs, field, dgettext("errors", "can't be changed"))
        end)
    end
  end

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
