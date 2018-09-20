# The following Poison.Encoder implementations ensure that JSON-encoding an
# Ecto changeset or record doesn't result in errors because of un-encodable
# constructs (such as keyword lists).

defimpl Poison.Encoder, for: Ecto.Changeset do
  import JumubaseWeb.ErrorHelpers, only: [translate_error: 1]

  def encode(changeset, options) do
    output = %{
      data: changeset.data,
      changes: changeset.changes,
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
    Poison.encode!(output, options)
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

