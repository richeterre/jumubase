defmodule JumubaseWeb.Schema.Query.PerformancesTest do
  use JumubaseWeb.ConnCase, async: true

  describe "performances" do
    test "returns scheduled performances of a public contest", %{conn: conn} do
      c = insert(:contest, timetables_public: true)

      p1 = insert_scheduled_performance(c)
      p2 = insert_scheduled_performance(c)

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
      insert_scheduled_performance(c)

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

    test "does not return unscheduled performances", %{conn: conn} do
      c = insert(:contest, timetables_public: true)
      insert_performance(c)

      query = """
      query Performances($contestId: ID!) {
        performances(contestId: $contestId) { id }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

      assert response = json_response(conn, 200)
      assert response["data"] == %{"performances" => []}
    end

    test "allows filtering of performances", %{conn: conn} do
      %{stages: [s1, s2]} = h = insert(:host, stages: build_list(2, :stage))
      c = insert(:contest, host: h, timetables_public: true)
      cc1 = insert_contest_category(c)
      cc2 = insert_contest_category(c)

      p = insert_performance(cc1, stage: s1, stage_time: ~N[2019-01-01 09:00:00])
      # Different contest category:
      insert_performance(cc2, stage: s1, stage_time: ~N[2019-01-01 10:00:00])
      # Different date:
      insert_performance(cc1, stage: s1, stage_time: ~N[2019-01-02 09:00:00])
      # Different stage:
      insert_performance(cc1, stage: s2)

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
            "filter" => %{
              "contestCategoryId" => cc1.id,
              "stageDate" => "2019-01-01",
              "stageId" => s1.id
            }
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

    test "returns predecessor host fields if available, or else nil", %{conn: conn} do
      rw = insert(:contest, round: 1, host: build(:host, name: "DS Helsinki", country_code: "FI"))
      lw = insert(:contest, round: 2, timetables_public: true)

      p1 = insert_scheduled_performance(lw, predecessor_contest: rw)
      p2 = insert_scheduled_performance(lw, predecessor_contest: nil)

      query = """
      query Performances($contestId: ID!) {
        performances(contestId: $contestId) { id predecessorHost { name countryCode } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"contestId" => lw.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performances" => [
                   %{
                     "id" => "#{p1.id}",
                     "predecessorHost" => %{"name" => "DS Helsinki", "countryCode" => "FI"}
                   },
                   %{
                     "id" => "#{p2.id}",
                     "predecessorHost" => nil
                   }
                 ]
               }
             }
    end
  end

  describe "performance" do
    test "returns a single performance", %{conn: conn} do
      c = insert(:contest, timetables_public: true)
      cc = insert(:contest_category, contest: c, category: build(:category, name: "Violine solo"))

      p =
        insert_scheduled_performance(cc,
          stage_time: ~N[2019-01-01 09:45:00],
          age_group: "IV",
          appearances: [
            build(:appearance,
              role: "soloist",
              participant: build(:participant, given_name: "A", family_name: "B"),
              instrument: "violin"
            ),
            build(:appearance,
              role: "accompanist",
              participant: build(:participant, given_name: "C", family_name: "D"),
              instrument: "piano"
            )
          ],
          pieces: [
            build(:piece,
              composer: "John Cage",
              composer_born: "1912",
              composer_died: "1992",
              title: "4′33″"
            )
          ]
        )

      query = """
      query Performance($id: ID!) {
        performance(id: $id) {
          id
          stageTime
          categoryName
          ageGroup
          appearances {
            participantName
            instrumentName
            isAccompanist
          }
          pieces {
            personInfo
            title
          }
        }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{
                   "id" => "#{p.id}",
                   "stageTime" => "09:45:00",
                   "categoryName" => "Violine solo",
                   "ageGroup" => "IV",
                   "appearances" => [
                     %{
                       "participantName" => "A B",
                       "instrumentName" => "Violin",
                       "isAccompanist" => false
                     },
                     %{
                       "participantName" => "C D",
                       "instrumentName" => "Piano",
                       "isAccompanist" => true
                     }
                   ],
                   "pieces" => [%{"personInfo" => "John Cage (1912–1992)", "title" => "4′33″"}]
                 }
               }
             }
    end

    test "returns predecessor host fields when available", %{conn: conn} do
      h = build(:host, name: "DS Helsinki", country_code: "FI")
      rw = insert(:contest, host: h, round: 1)
      lw = insert(:contest, round: 2, timetables_public: true)
      p = insert_scheduled_performance(lw, predecessor_contest: rw)

      query = """
      query Performance($id: ID!) {
        performance(id: $id) { predecessorHost { name countryCode } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{
                   "predecessorHost" => %{"name" => "DS Helsinki", "countryCode" => "FI"}
                 }
               }
             }
    end

    test "returns nil for a missing predecessor host", %{conn: conn} do
      c = insert(:contest, timetables_public: true)
      p = insert_scheduled_performance(c, predecessor_contest: nil)

      query = """
      query Performance($id: ID!) {
        performance(id: $id) { predecessorHost { name countryCode } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{"predecessorHost" => nil}
               }
             }
    end

    test "returns appearances in role order", %{conn: conn} do
      c = insert(:contest, timetables_public: true)

      p =
        insert_scheduled_performance(c,
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
      query Performance($id: ID!) {
        performance(id: $id) { appearances { participantName } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{
                   "appearances" => [
                     %{"participantName" => "A B"},
                     %{"participantName" => "E F"},
                     %{"participantName" => "C D"}
                   ]
                 }
               }
             }
    end

    test "returns appearance results when they are available and public", %{conn: conn} do
      c = insert(:contest, timetables_public: true)

      p =
        insert_scheduled_performance(c,
          appearances: [
            build(:appearance, role: "soloist", points: 25),
            build(:appearance, role: "accompanist", points: 5),
            build(:appearance, role: "accompanist", points: nil)
          ],
          results_public: true
        )

      query = """
      query Performance($id: ID!) {
        performance(id: $id) { appearances { result { points prize advances } } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{
                   "appearances" => [
                     %{"result" => %{"points" => 25, "prize" => "1. Preis", "advances" => true}},
                     %{"result" => %{"points" => 5, "prize" => nil, "advances" => false}},
                     %{"result" => nil}
                   ]
                 }
               }
             }
    end

    test "returns nil for a non-public result", %{conn: conn} do
      c = insert(:contest, timetables_public: true)

      p =
        insert_scheduled_performance(c,
          appearances: [build(:appearance, role: "soloist", points: 23)],
          results_public: false
        )

      query = """
      query Performance($id: ID!) {
        performance(id: $id) { appearances { result { points } } }
      }
      """

      conn = get(conn, "/graphql", query: query, variables: %{"id" => p.id})

      assert json_response(conn, 200) == %{
               "data" => %{
                 "performance" => %{
                   "appearances" => [%{"result" => nil}]
                 }
               }
             }
    end

    test "returns nil for a performance from a non-public contest", %{conn: conn} do
      c = insert(:contest, timetables_public: false)
      p = insert_scheduled_performance(c)

      conn |> assert_nil_performance(p.id)
    end

    test "returns nil for an unscheduled performance", %{conn: conn} do
      c = insert(:contest, timetables_public: true)
      p = insert_performance(c)

      conn |> assert_nil_performance(p.id)
    end

    test "returns nil for an unknown performance", %{conn: conn} do
      conn |> assert_nil_performance(123)
    end
  end

  # Private helpers

  # Queries the performance with the given ID and asserts a nil response with an error message.
  defp assert_nil_performance(conn, p_id) do
    query = """
    query Performance($id: ID!) {
      performance(id: $id) { id }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"id" => p_id})

    assert response = json_response(conn, 200)
    assert response["data"] == %{"performance" => nil}
    assert [%{"message" => "No public performance found for this ID"}] = response["errors"]
  end
end
