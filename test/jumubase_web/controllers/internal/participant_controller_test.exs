defmodule JumubaseWeb.Internal.ParticipantControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    login_if_needed(config)
  end

  describe "index/2" do
    setup config do
      Map.put(config, :contest, insert(:contest, round: 1))
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "lists a contest's participants to #{role} users", %{conn: conn, contest: c} do
        conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Participants"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's participants to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Participants"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's participants", %{
      conn: conn,
      contest: c
    } do
      conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's participants", %{
      conn: conn,
      contest: c
    } do
      conn = get(conn, Routes.internal_contest_participant_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  describe "show/2" do
    setup config do
      Map.put(config, :contest, insert(:contest, round: 1))
    end

    for role <- roles_except("local-organizer") do
      @tag login_as: role
      test "shows a single participant to #{role} users", %{conn: conn, contest: c} do
        pt = insert_participant(c, given_name: "X", family_name: "Y")
        conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
        assert html_response(conn, 200) =~ "X Y"
      end
    end

    @tag login_as: "local-organizer"
    test "shows a participant from an own contest to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      pt = insert_participant(own_c, given_name: "X", family_name: "Y")
      conn = get(conn, Routes.internal_contest_participant_path(conn, :show, own_c, pt))
      assert html_response(conn, 200) =~ "X Y"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to view a participant from a foreign contest", %{
      conn: conn,
      contest: c
    } do
      pt = insert_participant(c)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to view a participant", %{conn: conn, contest: c} do
      pt = insert_participant(c)
      conn = get(conn, Routes.internal_contest_participant_path(conn, :show, c, pt))
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

    test "redirects guests when trying to send welcome emails", %{conn: conn, contest: c} do
      conn |> attempt_send_welcome_emails(c) |> assert_unauthorized_guest
    end
  end

  # Private helpers

  defp attempt_send_welcome_emails(conn, contest) do
    post(conn, Routes.internal_contest_participant_path(conn, :send_welcome_emails, contest))
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
end
