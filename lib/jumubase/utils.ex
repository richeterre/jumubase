defmodule Jumubase.Utils do

  @doc """
  Returns the ids of the given items.
  """
  def get_ids(items), do: Enum.map(items, &(&1.id))

  @doc """
  Returns a regex for checking an email address format.
  """
  def email_format, do: ~r/.+\@.+\..+/

  @doc """
  Returns a list of the most common element(s) in the given list.
  """
  def mode([]), do: []
  def mode(list) when is_list(list) do
    grouped_list = Enum.group_by(list, &(&1))
    max =
      grouped_list
      |> Enum.map(fn {_, val} -> length(val) end)
      |> Enum.max

    for {key, val} <- grouped_list, length(val) == max, do: key
  end

  def parse_bool(string) when string in ~w(true false) do
    String.to_existing_atom(string)
  end
  def parse_bool(bool) when is_boolean(bool), do: bool
end
