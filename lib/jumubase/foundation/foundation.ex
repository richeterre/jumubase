defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  alias Jumubase.Repo
  alias Jumubase.Foundation.{Contest, ContestCategory, Host}

  def list_hosts do
    Repo.all(Host)
  end
  def list_hosts(ids) do
    Repo.all(from h in Host, where: h.id in ^ids)
  end

  def list_contests do
    Repo.all(Contest) |> Repo.preload(:host)
  end

  @doc """
  Returns a list of contests that participants can register for.
  """
  def list_open_contests do
    query = from c in Contest,
      where: c.round < 2,
      where: c.deadline >= ^Timex.today, # uses UTC
      join: h in assoc(c, :host),
      order_by: [h.name, {:desc, c.round}],
      preload: [host: h]

    Repo.all(query)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
  end

  def load_contest_categories(%Contest{} = contest) do
    Repo.preload(contest, [contest_categories: :category])
  end

  @doc """
  Gets a single contest category from the given contest.

  Raises `Ecto.NoResultsError` if the contest category isn't found in that contest.
  """
  def get_contest_category!(%Contest{id: contest_id}, id) do
    ContestCategory
    |> where([cc], cc.contest_id == ^contest_id)
    |> preload([_], :category)
    |> Repo.get!(id)
  end
end
