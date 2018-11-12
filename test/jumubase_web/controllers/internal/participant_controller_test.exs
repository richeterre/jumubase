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
        conn = get(conn, internal_contest_participant_path(conn, :index, c))
        assert html_response(conn, 200) =~ "Participants"
      end
    end

    @tag login_as: "local-organizer"
    test "lists an own contest's participants to local organizers", %{conn: conn, user: u} do
      own_c = insert_own_contest(u)
      conn = get(conn, internal_contest_participant_path(conn, :index, own_c))
      assert html_response(conn, 200) =~ "Participants"
    end

    @tag login_as: "local-organizer"
    test "redirects local organizers when trying to list a foreign contest's participants", %{conn: conn, contest: c} do
      conn = get(conn, internal_contest_participant_path(conn, :index, c))
      assert_unauthorized_user(conn)
    end

    test "redirects guests when trying to list a contest's participants", %{conn: conn, contest: c} do
      conn = get(conn, internal_contest_participant_path(conn, :index, c))
      assert_unauthorized_guest(conn)
    end
  end

  # Private helpers

  defp insert_own_contest(user) do
    insert(:contest, host: insert(:host, users: [user]))
  end
end
