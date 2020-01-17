defmodule JumubaseWeb.Internal.Permit do
  import Ecto.Query
  alias Jumubase.Utils
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, Host}

  @doc """
  Limits the query to contests that the user may access.
  """
  def scope_contests(query, %User{role: "local-organizer"} = user) do
    query |> at_own_host(user)
  end

  def scope_contests(query, %User{role: "global-organizer"} = user) do
    query |> in_own_host_groupings(user)
  end

  def scope_contests(query, %User{}), do: query

  def authorized?(%User{role: "local-organizer"} = u, %Contest{} = c) do
    %{host: %{users: users}} = Foundation.load_host_users(c)
    u.id in Utils.get_ids(users)
  end

  def authorized?(%User{role: "global-organizer"} = u, %Contest{} = c) do
    Foundation.list_hosts_for_user(u)
    |> Enum.any?(&(&1.current_grouping == c.grouping))
  end

  def authorized?(%User{}, %Contest{}), do: true

  def authorized?(%User{role: role}, :migrate_advancing) do
    role == "admin"
  end

  def authorized?(%User{role: role}, :export_advancing) do
    role in ["admin", "observer"]
  end

  # Private helpers

  # Excludes contests not hosted at one of the user's hosts.
  defp at_own_host(contests_query, %User{} = user) do
    from c in contests_query,
      join: h in assoc(c, :host),
      join: u in assoc(h, :users),
      where: u.id == ^user.id
  end

  # Excludes contests not hosted at one of the user's hosts.
  defp in_own_host_groupings(contests_query, %User{} = user) do
    user_host_query = from h in Host, join: u in assoc(h, :users), where: u.id == ^user.id

    from c in contests_query,
      join: h in subquery(user_host_query),
      on: h.current_grouping == c.grouping,
      distinct: true
  end
end
