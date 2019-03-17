defmodule JumubaseWeb.AuthHelpers do
  alias Jumubase.Accounts.User

  @doc """
  Returns whether the given user is an admin.
  """
  def admin?(%User{role: role}), do: role === "admin"
end
