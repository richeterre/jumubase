defmodule JumubaseWeb.Schema.Query.PerformancesTest do
  use JumubaseWeb.ConnCase, async: true

  test "returns performances of a public contest", %{conn: conn} do
    c = insert(:contest, timetables_public: true)

    p1 = insert_performance(c)
    p2 = insert_performance(c)

    query = """
    query Performances($contestId: ID!) {
      performances(contestId: $contestId) { id }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "performances" => [
                 %{"id" => "#{p1.id}"},
                 %{"id" => "#{p2.id}"}
               ]
             }
           }
  end

  test "does not return performances for a non-public contest", %{conn: conn} do
    c = insert(:contest, timetables_public: false)
    insert_performance(c)

    query = """
    query Performances($contestId: ID!) {
      performances(contestId: $contestId) { id }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert response = json_response(conn, 200)
    assert response["data"] == %{"performances" => nil}
    assert [%{"message" => "No public contest found for this ID"}] = response["errors"]
  end

  test "allows filtering of performances", %{conn: conn} do
    %{stages: [s1, s2]} = h = insert(:host, stages: build_list(2, :stage))
    c = insert(:contest, host: h, timetables_public: true)

    p = insert_performance(c, stage: s1, stage_time: ~N[2019-01-01 09:00:00])
    insert_performance(c, stage: s1, stage_time: ~N[2019-01-02 09:00:00])
    insert_performance(c, stage: s2)

    query = """
    query Performances($contestId: ID!, $filter: PerformanceFilter) {
      performances(contestId: $contestId, filter: $filter) { id }
    }
    """

    conn =
      get(conn, "/graphql",
        query: query,
        variables: %{
          "contestId" => c.id,
          "filter" => %{"stageId" => s1.id, "stageDate" => "2019-01-01"}
        }
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "performances" => [
                 %{"id" => "#{p.id}"}
               ]
             }
           }
  end

  test "returns all performance fields", %{conn: conn} do
    %{stages: [s]} = h = insert(:host, stages: [build(:stage)])
    c = insert(:contest, host: h, timetables_public: true)
    cc = insert(:contest_category, contest: c, category: build(:category, name: "Tuba solo"))

    p =
      insert_performance(cc,
        stage: s,
        stage_time: ~N[2019-01-01 09:00:00],
        age_group: "IV",
        appearances: [
          build(:appearance,
            role: "soloist",
            participant: build(:participant, given_name: "A", family_name: "B"),
            instrument: "violin"
          )
        ]
      )

    query = """
    query Performances($contestId: ID!) {
      performances(contestId: $contestId) {
        id
        stageTime
        categoryInfo
        appearances {
          participantName
          instrumentName
        }
      }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "performances" => [
                 %{
                   "id" => "#{p.id}",
                   "stageTime" => "09:00:00",
                   "categoryInfo" => "Tuba solo, AG IV",
                   "appearances" => [%{"participantName" => "A B", "instrumentName" => "Violin"}]
                 }
               ]
             }
           }
  end

  test "returns performance appearances in role order", %{conn: conn} do
    %{stages: [s]} = h = insert(:host, stages: [build(:stage)])
    c = insert(:contest, host: h, timetables_public: true)

    insert_performance(c,
      stage: s,
      # stage_time: ~N[2019-01-01 09:00:00],
      appearances: [
        build(:appearance,
          role: "ensemblist",
          participant: build(:participant, given_name: "A", family_name: "B")
        ),
        build(:appearance,
          role: "accompanist",
          participant: build(:participant, given_name: "C", family_name: "D")
        ),
        build(:appearance,
          role: "ensemblist",
          participant: build(:participant, given_name: "E", family_name: "F")
        )
      ]
    )

    query = """
    query Performances($contestId: ID!) {
      performances(contestId: $contestId) { appearances { participantName } }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "performances" => [
                 %{
                   "appearances" => [
                     %{"participantName" => "A B"},
                     %{"participantName" => "E F"},
                     %{"participantName" => "C D"}
                   ]
                 }
               ]
             }
           }
  end
end
