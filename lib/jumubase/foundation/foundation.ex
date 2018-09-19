defmodule Jumubase.Foundation do
  @moduledoc """
  The boundary for the Foundation system, which manages fundamental
  prerequisites of the competition such as categories, venues…
  """

  import Ecto.Query
  alias Jumubase.Repo
  alias Jumubase.Foundation.{Contest, Host}

  def list_hosts do
    Repo.all(Host)
  end
  def list_hosts(ids) do
    Repo.all(from h in Host, where: h.id in ^ids)
  end

  @doc """
  Returns a list of contests that participants can sign up for.
  """
  def list_open_contests do
    query = from c in Contest,
      where: c.round == 1,
      where: c.signup_deadline >= ^Timex.today, # uses UTC
      preload: :host

    Repo.all(query)
  end

  def get_contest!(id) do
    Repo.get!(Contest, id) |> Repo.preload(:host)
  end

  def load_contest_categories(%Contest{} = contest) do
    Repo.preload(contest, [contest_categories: :category])
  end
end
