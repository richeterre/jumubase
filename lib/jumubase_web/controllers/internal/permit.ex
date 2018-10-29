defmodule JumubaseWeb.Internal.Permit do
  import Ecto.Query
  alias Jumubase.Accounts
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation

  @doc """
  Limits the query to contests that the user may access.
  """
  def scope_contests(query, %User{role: "local-organizer"} = user) do
    query |> at_own_host(user)
  end
  def scope_contests(query, %User{}), do: query

  def accessible_contest?(%User{role: "local-organizer"} = user, c_id) do
    %{hosts: hosts} = Accounts.load_hosts(user)
    Foundation.get_contest(c_id, hosts) != nil
  end
  def accessible_contest?(%User{}, _id), do: true

  # Private helpers

  # Excludes contests not hosted at one of the user's hosts.
  defp at_own_host(contests_query, %User{} = user) do
    from c in contests_query,
      join: h in assoc(c, :host),
      join: u in assoc(h, :users),
      where: u.id == ^user.id
  end
end
