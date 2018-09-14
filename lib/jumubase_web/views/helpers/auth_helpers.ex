defmodule JumubaseWeb.AuthHelpers do

  @doc """
  Returns whether the given user is an admin.
  """
  def admin?(user), do: user.role === "admin"
end
