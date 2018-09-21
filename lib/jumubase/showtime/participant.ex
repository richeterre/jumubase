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
    |> validate_format(:email, ~r/.+\@.+\..+/)
    |> sanitize_text_input
  end

  # Private helpers

  defp sanitize_text_input(changeset) do
    changeset
    |> update_change(:given_name, &String.trim/1)
    |> update_change(:family_name, &String.trim/1)
    |> update_change(:phone, &String.trim/1)
    |> update_change(:email, &String.trim/1)
  end
end
