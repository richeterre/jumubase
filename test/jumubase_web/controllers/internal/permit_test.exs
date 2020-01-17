defmodule JumubaseWeb.Internal.PermitTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Repo
  alias Jumubase.Foundation.Contest
  alias JumubaseWeb.Internal.Permit

  setup %{role: role} do
    [user: insert(:user, role: role)]
  end

  describe "scope_contests/2" do
    @tag role: "local-organizer"
    test "returns only contests by own hosts to local organizers", %{user: u} do
      own_host_1 = build(:host, users: [u])
      own_host_2 = build(:host, users: [u, build(:user)])

      c1 = insert(:contest, host: own_host_1)
      c2 = insert(:contest, host: own_host_2)
      insert(:contest)

      assert_ids_match_unordered(
        Permit.scope_contests(Contest, u) |> Repo.all(),
        [c1, c2]
      )
    end

    @tag role: "global-organizer"
    test "returns only contests within own hosts' groupings to global organizers", %{user: u} do
      insert(:host, current_grouping: "1", users: [u])
      insert(:host, current_grouping: "2", users: [u, build(:user)])

      c1 = insert(:contest, grouping: "1")
      c2 = insert(:contest, grouping: "2")
      insert(:contest, grouping: "3")

      assert_ids_match_unordered(
        Permit.scope_contests(Contest, u) |> Repo.all(),
        [c1, c2]
      )
    end

    for role <- roles_except(["local-organizer", "global-organizer"]) do
      @tag role: role
      test "returns all contests to #{role} users", %{user: u} do
        own_host_1 = build(:host, current_grouping: "1", users: [u])
        own_host_2 = build(:host, current_grouping: "2", users: [u, build(:user)])

        c1 = insert(:contest, grouping: "1", host: own_host_1)
        c2 = insert(:contest, grouping: "2", host: own_host_2)
        c3 = insert(:contest, grouping: "3")

        assert_ids_match_unordered(
          Permit.scope_contests(Contest, u) |> Repo.all(),
          [c1, c2, c3]
        )
      end
    end
  end

  describe "authorized?/2" do
    @tag role: "local-organizer"
    test "checks whether contest is by own host for local organizers", %{user: u} do
      own_host_1 = build(:host, users: [u])
      own_host_2 = build(:host, users: [u, build(:user)])

      c1 = insert(:contest, host: own_host_1)
      c2 = insert(:contest, host: own_host_2)
      c3 = insert(:contest)

      assert Permit.authorized?(u, c1)
      assert Permit.authorized?(u, c2)
      refute Permit.authorized?(u, c3)
    end

    @tag role: "global-organizer"
    test "checks whether contest is in own hosts' groupings for global organizers", %{user: u} do
      insert(:host, current_grouping: "1", users: [u])
      insert(:host, current_grouping: "2", users: [u, build(:user)])

      c1 = insert(:contest, grouping: "1")
      c2 = insert(:contest, grouping: "2")
      c3 = insert(:contest, grouping: "3")

      assert Permit.authorized?(u, c1)
      assert Permit.authorized?(u, c2)
      refute Permit.authorized?(u, c3)
    end

    for role <- roles_except(["local-organizer", "global-organizer"]) do
      @tag role: role
      test "gives access to any contest to #{role} users", %{user: u} do
        own_host_1 = build(:host, current_grouping: "1", users: [u])
        own_host_2 = build(:host, current_grouping: "2", users: [u, build(:user)])

        c1 = insert(:contest, grouping: "1", host: own_host_1)
        c2 = insert(:contest, grouping: "2", host: own_host_2)
        c3 = insert(:contest, grouping: "3")

        assert Permit.authorized?(u, c1)
        assert Permit.authorized?(u, c2)
        assert Permit.authorized?(u, c3)
      end
    end

    @tag role: "admin"
    test "lets admins migrate advancing performances", %{user: u} do
      assert Permit.authorized?(u, :migrate_advancing)
    end

    for role <- roles_except("admin") do
      @tag role: role
      test "does not let #{role} users migrate advancing performances", %{user: u} do
        refute Permit.authorized?(u, :migrate_advancing)
      end
    end

    for role <- ["admin", "observer"] do
      @tag role: role
      test "lets #{role} users export advancing performances", %{user: u} do
        assert Permit.authorized?(u, :export_advancing)
      end
    end

    for role <- roles_except(["admin", "observer"]) do
      @tag role: role
      test "does not let #{role} users export advancing performances", %{user: u} do
        refute Permit.authorized?(u, :export_advancing)
      end
    end
  end
end
