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
        Permit.scope_contests(Contest, u) |> Repo.all,
        [c1, c2]
      )
    end

    for role <- roles_except("local-organizer") do
      @tag role: role
      test "returns all contests to #{role} users", %{user: u} do
        own_host_1 = build(:host, users: [u])
        own_host_2 = build(:host, users: [u, build(:user)])

        c1 = insert(:contest, host: own_host_1)
        c2 = insert(:contest, host: own_host_2)
        c3 = insert(:contest)

        assert_ids_match_unordered(
          Permit.scope_contests(Contest, u) |> Repo.all,
          [c1, c2, c3]
        )
      end
    end
  end

  describe "accessible contest/2" do
    @tag role: "local-organizer"
    test "checks whether contest is by own host for local organizers", %{user: u} do
      own_host_1 = build(:host, users: [u])
      own_host_2 = build(:host, users: [u, build(:user)])

      c1 = insert(:contest, host: own_host_1)
      c2 = insert(:contest, host: own_host_2)
      c3 = insert(:contest)

      assert Permit.accessible_contest?(u, c1.id)
      assert Permit.accessible_contest?(u, c2.id)
      refute Permit.accessible_contest?(u, c3.id)
    end

    for role <- roles_except("local-organizer") do
      @tag role: role
      test "gives access to any contest to #{role} users", %{user: u} do
        own_host_1 = build(:host, users: [u])
        own_host_2 = build(:host, users: [u, build(:user)])

        c1 = insert(:contest, host: own_host_1)
        c2 = insert(:contest, host: own_host_2)
        c3 = insert(:contest)

        assert Permit.accessible_contest?(u, c1.id)
        assert Permit.accessible_contest?(u, c2.id)
        assert Permit.accessible_contest?(u, c3.id)
      end
    end
  end
end
