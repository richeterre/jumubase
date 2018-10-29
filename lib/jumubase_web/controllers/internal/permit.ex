defmodule JumubaseWeb.Internal.Permit do
  import Ecto.Query
  alias Jumubase.Accounts.User

  @doc """
  Limits the query to contests that the user may access.
  """
  def scope_contests(query, %User{role: "local-organizer"} = user) do
    from c in query,
      join: h in assoc(c, :host),
      join: u in assoc(h, :users),
      where: u.id == ^user.id
  end
  def scope_contests(query, %User{}), do: query
end
