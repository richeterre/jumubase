defmodule JumubaseWeb.AuthHelpers do
  @doc """
  Returns whether the given user is an admin.
  """
  def admin?(%User{role: role}), do: role === "admin"
end
