defmodule JumubaseWeb.PerformanceLive.EditTest do
  use JumubaseWeb.ConnCase
  use Bamboo.Test, shared: true
  import Phoenix.LiveViewTest
  alias Jumubase.Repo
  alias Jumubase.Showtime.Performance

  setup config do
    contest =
      insert(:contest, deadline: Timex.today(), allows_registration: true)
      |> with_contest_categories

    Map.put(config, :contest, contest)
  end

  test "mounts the registration form", %{conn: conn, contest: c} do
    {_, html} = live_new(conn, c)
    assert html =~ "Submit registration"
  end

  test "lets the user register a new performance", %{conn: conn, contest: c} do
    [cc, _] = c.contest_categories
    {view, _} = live_new(conn, c)

    render_submit(view, :submit, valid_performance_params(cc))
    %Performance{edit_code: edit_code} = get_inserted_performance()

    flash = assert_redirect(view, "/")

    assert flash["success"] =~
             "We received your registration! You can still change it later using the edit code #{
               edit_code
             }."
  end

  test "sends a confirmation email upon registration", %{conn: conn, contest: c} do
    [cc, _] = c.contest_categories
    {view, _} = live_new(conn, c)

    render_submit(view, :submit, valid_performance_params(cc))
    performance = get_inserted_performance()

    assert_delivered_email(JumubaseWeb.Email.registration_success(performance))
  end

  # Private helpers

  defp live_new(conn, contest) do
    {:ok, view, html} =
      live_isolated(conn, JumubaseWeb.PerformanceLive.New,
        session: %{"contest_id" => contest.id, "submit_title" => "Submit registration"}
      )

    {view, html}
  end

  defp get_inserted_performance do
    Repo.one(Performance) |> Repo.preload(appearances: :participant)
  end
end
