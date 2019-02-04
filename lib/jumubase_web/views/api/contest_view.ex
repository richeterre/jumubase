defmodule JumubaseWeb.Api.ContestView do
  import JumubaseWeb.Internal.ContestView, only: [name: 1]
  import JumubaseWeb.Internal.ContestView, only: [name: 1]
  alias Jumubase.Foundation.{Contest, ContestCategory, Stage}

  def render("index.json", %{contests: contests}) do
    contests |> Enum.map(&render_contest/1)
  end

  # Private helpers

  defp render_contest(%Contest{host: h} = c) do
    %{
      id: to_string(c.id),
      name: name(c),
      host_country: h.country_code,
      time_zone: h.time_zone,
      start_date: to_utc_datetime(c.start_date),
      end_date: to_utc_datetime(c.end_date),
      venues: h.stages |> Enum.map(&render_stage/1),
      contest_categories: c.contest_categories |> Enum.map(&render_contest_category/1)
    }
  end

  defp render_stage(%Stage{} = s) do
    %{id: to_string(s.id), name: s.name}
  end

  defp render_contest_category(%ContestCategory{} = cc) do
    %{id: to_string(cc.id), name: cc.category.name}
  end

  defp to_utc_datetime(date) do
    {:ok, naive_datetime} = NaiveDateTime.new(date, ~T[00:00:00])
    naive_datetime |> DateTime.from_naive!("Etc/UTC")
  end
end
