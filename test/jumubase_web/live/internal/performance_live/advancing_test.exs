defmodule JumubaseWeb.Internal.PerformanceLive.AdvancingTest do
  use JumubaseWeb.ConnCase
  import Phoenix.LiveViewTest

  setup %{round: round} = config do
    season = 56
    grouping = "2"

    contest =
      insert(:contest, season: season, round: round, grouping: grouping)
      |> with_contest_categories()

    [cc | _] = contest.contest_categories

    # Create next-round target contest with matching category
    target_contest = insert(:contest, season: season, round: round + 1, grouping: grouping)
    insert(:contest_category, contest: target_contest, category: cc.category)

    config
    |> Map.put(:contest, contest)
    |> Map.put(:target_contest, target_contest)
    |> login_if_needed()
  end

  @tag round: 1
  @tag login_as: "admin"
  test "lets admins select a target contest for an RW", %{
    conn: conn,
    contest: c,
    target_contest: target_c
  } do
    {view, _html} = live_advancing(conn, c)

    assert has_migration_form?(view)
    assert view |> element("option[value=#{target_c.id}") |> has_element?()
  end

  for role <- roles_except("admin") do
    @tag round: 1
    @tag login_as: role
    test "does not let #{role} users select a target contest for an RW", %{conn: conn, contest: c} do
      {view, _html} = live_advancing(conn, c)

      refute has_migration_form?(view)
    end
  end

  for role <- all_roles() do
    @tag round: 2
    @tag login_as: role
    test "does not let #{role} users select a target contest for an LW", %{conn: conn, contest: c} do
      {view, _html} = live_advancing(conn, c)

      refute has_migration_form?(view)
    end
  end

  @tag round: 1
  @tag login_as: "admin"
  test "filters performances and enables submission when selecting a target contest", %{
    conn: conn,
    contest: c,
    target_contest: target_c
  } do
    [cc | _] = c.contest_categories
    # Create advancing performance in matching category
    insert_performance(cc,
      appearances:
        build_list(1, :appearance,
          role: "soloist",
          points: 23,
          participant: build(:participant, given_name: "Ella", family_name: "Eligible")
        )
    )

    # Create advancing performance in non-matching category
    insert_performance(c,
      appearances:
        build_list(1, :appearance,
          role: "soloist",
          points: 23,
          participant: build(:participant, given_name: "Irvin", family_name: "Ineligible")
        )
    )

    {view, _html} = live_advancing(conn, c)
    html = render_change(view, "change", %{"migration" => %{"target_contest_id" => target_c.id}})

    assert html =~ "1 performance"
    assert html =~ "Filter active"
    assert html =~ "Ella Eligible"
    refute html =~ "Irvin Ineligible"
    assert view |> element("button[type=submit]:not(disabled)") |> has_element?()
  end

  @tag round: 1
  @tag login_as: "admin"
  test "lets admins migrate performances", %{conn: conn, contest: c, target_contest: target_c} do
    [cc | _] = c.contest_categories
    # Create advancing performance in matching category
    insert_performance(cc, appearances: build_list(1, :appearance, role: "soloist", points: 23))

    {view, _html} = live_advancing(conn, c)

    # Select a target contest first
    render_change(view, "change", %{"migration" => %{"target_contest_id" => target_c.id}})

    {:ok, conn} =
      view
      |> render_submit("submit")
      |> follow_redirect(
        conn,
        Routes.internal_contest_performances_path(conn, :advancing, c)
      )

    assert html_response(conn, 200) =~ "One performance was migrated"
  end

  for role <- roles_except("admin") do
    @tag round: 1
    @tag login_as: "admin"
    test "does not let #{role} users migrate performances", %{
      conn: conn,
      contest: c,
      target_contest: target_c
    } do
      [cc | _] = c.contest_categories
      # Create advancing performance in matching category
      insert_performance(cc, appearances: build_list(1, :appearance, role: "soloist", points: 23))

      {view, _html} = live_advancing(conn, c)

      # Select a target contest first
      render_change(view, "change", %{"migration" => %{"target_contest_id" => target_c.id}})

      {:ok, conn} =
        view
        |> render_submit("submit")
        |> follow_redirect(
          conn,
          Routes.internal_contest_performances_path(conn, :advancing, c)
        )

      assert html_response(conn, 200) =~ "One performance was migrated"
    end
  end

  for role <- all_roles() do
    @tag round: 1
    @tag login_as: role
    test "does not let #{role} users export advancing RW performances", %{conn: conn, contest: c} do
      {_view, html} = live_advancing(conn, c)

      refute html =~ "Export for JMDaten"
    end
  end

  for role <- ["admin", "observer"] do
    @tag round: 2
    @tag login_as: role
    test "lets #{role} users export advancing LW performances", %{conn: conn, contest: c} do
      {_view, html} = live_advancing(conn, c)

      assert html =~ "Export for JMDaten"
    end
  end

  for role <- roles_except(["admin", "observer"]) do
    @tag round: 2
    @tag login_as: role
    test "does not let #{role} users export advancing LW performances", %{conn: conn, contest: c} do
      {_view, html} = live_advancing(conn, c)

      refute html =~ "Export for JMDaten"
    end
  end

  # Private helpers

  defp live_advancing(conn, contest) do
    {:ok, view, html} =
      live_isolated(conn, JumubaseWeb.Internal.PerformanceLive.Advancing,
        session: %{"contest_id" => contest.id}
      )

    {view, html}
  end

  defp has_migration_form?(view) do
    view |> element("select#migration_target_contest_id") |> has_element?() and
      view |> element("button[type=submit]") |> has_element?()
  end
end
