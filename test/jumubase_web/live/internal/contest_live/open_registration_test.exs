defmodule JumubaseWeb.Internal.ContestLive.OpenRegistrationTest do
  use JumubaseWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Jumubase.Repo
  alias Jumubase.Foundation.Contest

  setup config do
    contest = insert(:contest, dates_verified: false, allows_registration: false)

    config
    |> Map.put(:contest, contest)
    |> login_if_needed()
  end

  @tag login_as: "admin"
  test "mounts the registration form", %{conn: conn, contest: c} do
    {_, html} = live_open_registration(conn, c)
    assert html =~ "Confirm and Open Registration"
  end

  @tag login_as: "admin"
  test "lets the user open registration for the contest", %{conn: conn, contest: c} do
    {view, _} = live_open_registration(conn, c)

    new_deadline = Timex.shift(c.deadline, days: 1)
    new_start_date = Timex.shift(c.start_date, days: 1)
    new_end_date = Timex.shift(c.end_date, days: 1)
    new_certificate_date = Timex.shift(c.end_date, days: 2)

    valid_params = %{
      "contest" => %{
        "deadline" => new_deadline,
        "start_date" => new_start_date,
        "end_date" => new_end_date,
        "certificate_date" => new_certificate_date
      }
    }

    view
    |> form("form", valid_params)
    |> render_submit()

    assert %Contest{
             dates_verified: true,
             allows_registration: true,
             deadline: ^new_deadline,
             start_date: ^new_start_date,
             end_date: ^new_end_date,
             certificate_date: ^new_certificate_date
           } = get_updated_contest(c)

    flash = assert_redirect(view, Routes.internal_contest_path(conn, :show, c))

    assert flash["success"] =~
             "Registration for your contest is now open. You can find the form on the registration page."
  end

  @tag login_as: "admin"
  test "shows form errors when user submits invalid data", %{conn: conn, contest: c} do
    {view, _} = live_open_registration(conn, c)

    invalid_end_date = Timex.shift(c.start_date, days: -1)

    html =
      view
      |> form("form", %{"contest" => %{"end_date" => invalid_end_date}})
      |> render_submit()

    assert view |> element(".has-error") |> has_element?()
    assert html =~ "can&#39;t be before the start date"

    assert %Contest{dates_verified: false, allows_registration: false} = get_updated_contest(c)
  end

  # Private helpers

  defp live_open_registration(conn, contest) do
    {:ok, view, html} =
      live_isolated(conn, JumubaseWeb.Internal.ContestLive.OpenRegistration,
        session: %{"contest_id" => contest.id}
      )

    {view, html}
  end

  defp get_updated_contest(contest) do
    Repo.get!(Contest, contest.id)
  end
end
