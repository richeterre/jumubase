defmodule Jumubase.Utils do

  @doc """
  Returns the ids of the given items.
  """
  def get_ids(items), do: Enum.map(items, &(&1.id))

  @doc """
  Returns a regex for checking an email address format.
  """
  def email_format, do: ~r/.+\@.+\..+/
end
