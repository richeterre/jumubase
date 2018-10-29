defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  alias Jumubase.Repo
  alias Jumubase.Utils
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host}

  def list_hosts do
    Repo.all(Host)
  end
  def list_hosts(ids) do
    Repo.all(from h in Host, where: h.id in ^ids)
  end

  def list_host_locations do
    Repo.all(from h in Host, select: {h.latitude, h.longitude})
  end

  def list_contests(query \\ Contest) do
    Repo.all(query) |> Repo.preload(:host)
  end

  @doc """
  Returns all contests in a round whose deadline has't passed.
  """
  def list_open_contests(round) do
    query = from c in Contest,
      where: c.round == ^round,
      where: c.deadline >= ^Timex.today, # uses UTC
      join: h in assoc(c, :host),
      order_by: [h.name, {:desc, c.round}],
      preload: [host: h]

    Repo.all(query)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
  end

  @doc """
  Returns a contest if found hosted by one of the given hosts.
  """
  def get_contest(id, hosts) do
    query = from c in Contest,
      where: c.host_id in ^Utils.get_ids(hosts)

    Repo.get(query, id) |> Repo.preload(:host)
  end

  def list_categories do
    Repo.all(Category)
  end

  def load_host_users(%Contest{} = contest) do
    Repo.preload(contest, [host: :users])
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

  @doc """
  Returns the most common deadline within the given contests.
  """
  def general_deadline(contests) do
    contests
    |> Enum.map(&(&1.deadline))
    |> Utils.mode
    |> List.first
  end
end
