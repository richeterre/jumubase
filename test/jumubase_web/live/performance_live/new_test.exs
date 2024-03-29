defmodule JumubaseWeb.PerformanceLive.NewTest do
  use JumubaseWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Jumubase.Repo
  alias Jumubase.Showtime.Performance
  import Swoosh.TestAssertions

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

  test "lets the user add appearances", %{conn: conn, contest: c} do
    {view, _} = live_new(conn, c)

    refute render(view) =~ "Participant 2"
    assert render_click(view, "add-appearance") =~ "Participant 2"
  end

  test "lets the user remove appearances", %{conn: conn, contest: c} do
    {view, _} = live_new(conn, c)

    assert render(view) =~ "Participant 1"
    refute render_click(view, "remove-appearance", %{"index" => "0"}) =~ "Participant 1"
  end

  test "lets the user add pieces", %{conn: conn, contest: c} do
    {view, _} = live_new(conn, c)

    refute render(view) =~ "Piece 2"
    assert render_click(view, "add-piece") =~ "Piece 2"
  end

  test "lets the user remove pieces", %{conn: conn, contest: c} do
    {view, _} = live_new(conn, c)

    assert render(view) =~ "Piece 1"
    refute render_click(view, "remove-piece", %{"index" => "0"}) =~ "Piece 1"
  end

  test "lets the user register a new performance", %{conn: conn, contest: c} do
    [cc, _] = c.contest_categories
    {view, _} = live_new(conn, c)

    view
    |> form("form", valid_performance_params(cc))
    |> render_submit()

    %Performance{edit_code: edit_code} = get_inserted_performance()

    flash = assert_redirect(view, "/")

    assert flash["success"] =~
             "We received your registration! You can still change it later using the edit code #{edit_code}."
  end

  test "sends a confirmation email upon registration", %{conn: conn, contest: c} do
    [cc, _] = c.contest_categories
    {view, _} = live_new(conn, c)

    view
    |> form("form", valid_performance_params(cc))
    |> render_submit()

    performance = get_inserted_performance()

    assert_email_sent(JumubaseWeb.Email.registration_success(performance))
  end

  test "shows form errors when user submits invalid data", %{conn: conn, contest: c} do
    [cc, _] = c.contest_categories
    {view, _} = live_new(conn, c)

    invalid_params = %{"performance" => %{"contest_category_id" => cc.id}}

    html =
      view
      |> form("form", invalid_params)
      |> render_submit()

    assert view |> element(".has-error") |> has_element?()
    assert html =~ "can&#39;t be blank"

    assert get_inserted_performance() == nil
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
