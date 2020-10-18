defmodule Jumubase.Utils do
  @doc """
  Returns the ids of the given items.
  """
  def get_ids(items), do: Enum.map(items, & &1.id)

  @doc """
  Parses ids from a string of comma-separated ids.

  ## Examples

    iex> Utils.parse_ids("")
    []

    iex> Utils.parse_ids("1")
    ["1"]

    iex> Utils.parse_ids("1,")
    ["1"]

    iex> Utils.parse_ids("1,2")
    ["1", "2"]
  """
  def parse_ids(id_string) do
    String.split(id_string, ",", trim: true)
  end

  @doc """
  Returns a regex for checking an email address format.
  """
  def email_format, do: ~r/.+\@.+\..+/

  def parse_bool(string) when string in ~w(true false) do
    String.to_existing_atom(string)
  end

  def parse_bool(bool) when is_boolean(bool), do: bool
end
