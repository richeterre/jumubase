# The following Poison.Encoder implementations ensure that JSON-encoding an
# Ecto changeset or record doesn't result in errors because of un-encodable
# constructs (such as keyword lists).

defimpl Poison.Encoder, for: Ecto.Changeset do
  import JumubaseWeb.ErrorHelpers, only: [translate_error: 1]

  def encode(changeset, options) do
    output = %{
      data: changeset.data,
      changes: changeset.changes,
      errors: get_errors(changeset),
      valid: changeset.valid?
    }
    Poison.encode!(output, options)
  end

  # Omit errors if changeset has no action (typically before first submission)
  defp get_errors(%Ecto.Changeset{action: nil}), do: []
  defp get_errors(%Ecto.Changeset{action: _} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end
end

defimpl Poison.Encoder, for: Ecto.Schema.Metadata do
  def encode(_metadata, _options) do
    Poison.encode!(nil)
  end
end

defimpl Poison.Encoder, for: Ecto.Association.NotLoaded do
  def encode(_metadata, _options) do
    Poison.encode!(nil)
  end
end
