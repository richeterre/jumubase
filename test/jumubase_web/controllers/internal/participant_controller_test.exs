defmodule JumubaseWeb.Internal.ParticipantControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Foundation.Contest

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lists a contest's participants to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Participants"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to list a contest's participants",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to list a contest's participants", %{conn: conn} do
      c = insert(:contest, round: 1)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "shows a single participant to authorized #{role} users", %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        pt = insert_participant(c, given_name: "X", family_name: "Y")
        conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
        assert html_response(conn, 200) =~ "X Y"
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to view a contest's participant",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        pt = insert_participant(c)
        conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to view a participant", %{conn: conn} do
      c = insert(:contest, round: 1)
      pt = insert_participant(c)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
      assert_unauthorized_guest(conn)
    end
  end

  describe "compare/2" do
    @tag login_as: "admin"
    test "lets admins compare two participants", %{conn: conn} do
      conn |> attempt_compare |> assert_compare_success
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to compare two participants", %{conn: conn} do
        conn |> attempt_compare |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to compare two participants", %{conn: conn} do
      conn |> attempt_compare |> assert_unauthorized_guest
    end
  end

  describe "merge/2" do
    setup config do
      Map.put(config, :contest, insert(:contest))
    end

    @tag login_as: "admin"
    test "lets admins merge two participants", %{conn: conn, contest: c} do
      conn |> attempt_merge(c) |> assert_merge_success(c)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to merge two participants", %{conn: conn, contest: c} do
        conn |> attempt_merge(c) |> assert_unauthorized_user()
      end
    end

    test "redirects guests trying to merge two participants", %{conn: conn, contest: c} do
      conn |> attempt_merge(c) |> assert_unauthorized_guest()
    end
  end

  describe "export_csv/2" do
    for role <- all_roles() do
      @tag login_as: role
      test "lets authorized #{role} users download a CSV of the contest's participants",
           %{conn: conn, user: u} do
        c = insert_authorized_contest(u)
        conn = get(conn, Routes.internal_contest_participant_path(conn, :export_csv, c))
        assert_csv_file_response(conn, "Teilnehmer.csv")
      end
    end

    for role <- ["local-organizer", "global-organizer"] do
      @tag login_as: role
      test "redirects unauthorized #{role} users trying to download a CSV of the contest's participants",
           %{conn: conn, user: u} do
        c = insert_unauthorized_contest(u)
        conn = get(conn, Routes.internal_contest_participant_path(conn, :export_csv, c))
        assert_unauthorized_user(conn)
      end
    end

    test "redirects guests trying to download a CSV of the contest's participants", %{conn: conn} do
      c = insert(:contest, round: 1)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :export_csv, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "send_welcome_emails/2" do
    setup config do
      Map.put(config, :contest, insert(:contest, round: 2))
    end

    @tag login_as: "admin"
    test "lets admins send welcome emails", %{conn: conn, contest: c} do
      conn |> attempt_send_welcome_emails(c) |> assert_send_welcome_emails_success(c)
    end

    for role <- roles_except("admin") do
      @tag login_as: role
      test "redirects #{role} users trying to send welcome emails", %{conn: conn, contest: c} do
        conn |> attempt_send_welcome_emails(c) |> assert_unauthorized_user
      end
    end

    test "redirects guests trying to send welcome emails", %{conn: conn, contest: c} do
      conn |> attempt_send_welcome_emails(c) |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_compare(conn) do
    c = insert(:contest)
    {pt1, pt2} = insert_participant_pair(c)
    get(conn, Routes.internal_contest_participant_path(conn, :compare, c, pt1.id, pt2.id))
  end

  defp assert_compare_success(conn) do
    assert html_response(conn, 200) =~ "Compare participants"
  end

  defp attempt_merge(conn, contest) do
    {pt1, pt2} = insert_participant_pair(contest)

    patch(
      conn,
      Routes.internal_contest_participant_path(conn, :merge, contest, pt1.id, pt2.id,
        merge_fields: %{given_name: true}
      )
    )
  end

  defp assert_merge_success(conn, contest) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_participant_path(conn, :duplicates, contest),
      "The participants were merged."
    )
  end

  defp attempt_send_welcome_emails(conn, contest) do
    post(conn, Routes.internal_contest_participant_path(conn, :send_welcome_emails, contest))
  end

  defp assert_csv_file_response(conn, filename) do
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/csv"]

    assert get_resp_header(conn, "content-disposition") == [
             "attachment; filename=\"#{filename}\""
           ]
  end

  defp assert_send_welcome_emails_success(conn, contest) do
    assert_flash_redirect(
      conn,
      Routes.internal_contest_participant_path(conn, :index, contest),
      "The welcome emails were sent."
    )
  end

  defp assert_flash_redirect(conn, redirect_path, message) do
    assert redirected_to(conn) == redirect_path
    # Follow redirection
    conn = get(recycle(conn), redirect_path)
    assert html_response(conn, 200) =~ message
  end

  defp insert_participant_pair(%Contest{} = c) do
    {insert_participant(c), insert_participant(c)}
  end
end
