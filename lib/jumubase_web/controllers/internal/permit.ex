defmodule JumubaseWeb.Internal.Permit do
  import Ecto.Query
  alias Jumubase.Accounts.User

  @doc """
  Limits the query to contests that the user may access.
  """
  def scope_contests(query, %User{role: "local-organizer"} = user) do
    query |> at_own_host(user)
  end
  def scope_contests(query, %User{}), do: query

  # Private helpers

  # Excludes contests not hosted at one of the user's hosts.
  defp at_own_host(contests_query, %User{} = user) do
    from c in contests_query,
      join: h in assoc(c, :host),
      join: u in assoc(h, :users),
      where: u.id == ^user.id
  end
end
