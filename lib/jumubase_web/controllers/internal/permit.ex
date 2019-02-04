defmodule JumubaseWeb.Internal.Permit do
  import Ecto.Query
  alias Jumubase.Utils
  alias Jumubase.Accounts.User
  alias Jumubase.Foundation
  alias Jumubase.Foundation.Contest

  @doc """
  Limits the query to contests that the user may access.
  """
  def scope_contests(query, %User{role: "local-organizer"} = user) do
    query |> at_own_host(user)
  end

  def scope_contests(query, %User{}), do: query

  def authorized?(%User{role: "local-organizer"} = u, %Contest{} = c) do
    %{host: %{users: users}} = Foundation.load_host_users(c)
    u.id in Utils.get_ids(users)
  end

  def authorized?(%User{}, %Contest{}), do: true

  # Private helpers

  # Excludes contests not hosted at one of the user's hosts.
  defp at_own_host(contests_query, %User{} = user) do
    from c in contests_query,
      join: h in assoc(c, :host),
      join: u in assoc(h, :users),
      where: u.id == ^user.id
  end
end
