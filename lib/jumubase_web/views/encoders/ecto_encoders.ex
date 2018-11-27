# The following Jason.Encoder implementations ensure that JSON-encoding an
# Ecto changeset or record doesn't result in errors because of un-encodable
# constructs (such as keyword lists).

require Protocol
alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}

# White-list schema fields that may be exposed via JSON
Protocol.derive(Jason.Encoder, Performance, only: [:id, :contest_category_id, :appearances, :pieces])
Protocol.derive(Jason.Encoder, Appearance, only: [:id, :instrument, :role, :participant])
Protocol.derive(Jason.Encoder, Participant, only: [:id, :given_name, :family_name, :birthdate, :phone, :email])
Protocol.derive(Jason.Encoder, Piece, only: [:id, :title, :composer, :composer_born, :composer_died, :artist, :epoch, :minutes, :seconds])

defimpl Jason.Encoder, for: Ecto.Changeset do
  import JumubaseWeb.ErrorHelpers, only: [translate_error: 1]

  def encode(changeset, _options) do
    data = if changeset.action == :insert, do: %{}, else: changeset.data

    output = %{
      data: data,
      changes: changeset.changes,
      errors: get_errors(changeset),
      valid: changeset.valid?
    }
    Jason.encode!(output)
  end

  # Omit errors if changeset has no action (typically before first submission)
  defp get_errors(%Ecto.Changeset{action: nil}), do: []
  defp get_errors(%Ecto.Changeset{action: _} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end
end

defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
  def encode(struct, opts) do
    Jason.Encode.list(Enum.to_list(struct), opts)
  end
end
