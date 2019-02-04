defmodule JumubaseWeb.Internal.ParticipantControllerTest do
  use JumubaseWeb.ConnCase

  setup config do
    config
    |> Map.put(:contest, insert(:contest))
    |> login_if_needed
  end

  describe "index/2" do
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
end
