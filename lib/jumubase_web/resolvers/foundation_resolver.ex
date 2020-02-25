defmodule JumubaseWeb.FoundationResolver do
  alias Jumubase.Foundation
  alias Jumubase.Foundation.{Contest, ContestCategory, Host}
  alias JumubaseWeb.Internal.ContestView

  def public_contests(_, _, _) do
    {:ok, Foundation.list_public_contests()}
  end

  def contest_categories(_, %{contest_id: c_id}, _) do
    case Foundation.get_public_contest(c_id) do
      nil -> {:error, "No public contest found for this ID"}
      contest -> {:ok, Foundation.list_contest_categories(contest)}
    end
  end

  def name(%Contest{} = c, _, _) do
    {:ok, ContestView.name(c)}
  end

  def name(%ContestCategory{} = cc, _, _) do
    {:ok, cc.category.name}
  end

  def dates(%Contest{} = c, _, _) do
    {:ok, Foundation.date_range(c) |> Enum.to_list()}
  end

  def stages(%Contest{} = c, _, _) do
    {:ok, c.host.stages}
  end

  def country_codes(%Host{} = h, _, _) do
    {:ok, Foundation.country_codes(h)}
  end

  def public_result_count(performances, _, _) do
    {:ok, performances |> Enum.count(& &1.results_public)}
  end
end
