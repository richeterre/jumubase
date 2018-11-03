defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  alias Jumubase.Repo
  alias Jumubase.Utils
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host}

  ## Hosts

  def list_hosts do
    Repo.all(Host)
  end
  def list_hosts(ids) do
    Repo.all(from h in Host, where: h.id in ^ids)
  end

  def list_host_locations do
    Repo.all(from h in Host, select: {h.latitude, h.longitude})
  end

  def create_host(attrs) do
    Host.changeset(%Host{}, attrs) |> Repo.insert
  end

  ## Contests

  def list_contests(query \\ Contest) do
    query = from c in query,
      join: h in assoc(c, :host),
      order_by: [{:desc, c.round}, h.name],
      preload: [host: h]

    Repo.all(query)
  end

  @doc """
  Returns all contests in a round whose deadline has't passed.
  """
  def list_open_contests(round) do
    query = from c in Contest,
      where: c.round == ^round,
      where: c.deadline >= ^Timex.today, # uses UTC
      join: h in assoc(c, :host),
      order_by: h.name,
      preload: [host: h]

    Repo.all(query)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
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

  ## Categories

  def list_categories do
    Repo.all(Category)
  end

  def create_category(attrs) do
    Category.changeset(%Category{}, attrs) |> Repo.insert
  end

  def list_contest_categories(%Contest{} = contest) do
    ContestCategory
    |> where(contest_id: ^contest.id)
    |> preload(:category)
    |> Repo.all
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

  ## Preloading

  def load_host_users(%Contest{} = contest) do
    Repo.preload(contest, [host: :users])
  end

  def load_contest_categories(%Contest{} = contest) do
    Repo.preload(contest, [contest_categories: :category])
  end
end
