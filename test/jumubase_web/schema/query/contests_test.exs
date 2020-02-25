defmodule JumubaseWeb.Schema.Query.ContestsTest do
  use JumubaseWeb.ConnCase, async: true

  test "returns all contests with public timetables", %{conn: conn} do
    %{stages: [s]} = h = insert(:host, stages: build_list(1, :stage))
    [c1, c2] = insert_list(2, :contest, host: h, timetables_public: true)
    [c3, c4] = insert_list(2, :contest, host: h, timetables_public: false)

    insert_performance(c1, stage: s)
    insert_performance(c2, stage: s)
    insert_performance(c3, stage: s)
    insert_performance(c4, stage: s)

    query = "query { contests { id } }"
    conn = get(conn, "/graphql", query: query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "contests" => [
                 %{"id" => "#{c1.id}"},
                 %{"id" => "#{c2.id}"}
               ]
             }
           }
  end

  test "returns all contest fields", %{conn: conn} do
    %{stages: [s]} =
      h =
      insert(:host,
        name: "Helsinki",
        country_code: "FI",
        stages: [build(:stage, name: "Aula")]
      )

    c =
      insert(:contest,
        host: h,
        season: 56,
        round: 1,
        start_date: ~D[2019-01-01],
        end_date: ~D[2019-01-03],
        timetables_public: true
      )

    insert_performance(c, stage: s, results_public: true)
    insert_performance(c, stage: s, results_public: false)

    query = """
    query {
      contests {
        id
        name
        host { id countryCodes }
        dates
        stages { id name }
      }
    }
    """

    conn = get(conn, "/graphql", query: query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "contests" => [
                 %{
                   "id" => "#{c.id}",
                   "name" => "RW Helsinki 2019",
                   "host" => %{"id" => "#{h.id}", "countryCodes" => ["FI"]},
                   "dates" => ["2019-01-01", "2019-01-02", "2019-01-03"],
                   "stages" => [
                     %{"id" => "#{s.id}", "name" => "Aula"}
                   ]
                 }
               ]
             }
           }
  end

  test "returns stages ordered by creation date", %{conn: conn} do
    h = insert(:host)
    now = Timex.now()
    s1 = insert(:stage, host: h, inserted_at: now)
    s2 = insert(:stage, host: h, inserted_at: now |> Timex.shift(seconds: 1))
    s3 = insert(:stage, host: h, inserted_at: now |> Timex.shift(seconds: -1))

    c = insert(:contest, host: h, timetables_public: true)

    insert_performance(c, stage: s1)
    insert_performance(c, stage: s2)
    insert_performance(c, stage: s3)

    query = "query { contests { stages { id } } }"

    conn = get(conn, "/graphql", query: query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "contests" => [
                 %{
                   "stages" => [
                     %{"id" => "#{s3.id}"},
                     %{"id" => "#{s1.id}"},
                     %{"id" => "#{s2.id}"}
                   ]
                 }
               ]
             }
           }
  end

  test "returns all featured contests", %{conn: conn} do
    %{stages: [s]} = h = insert(:host, stages: build_list(1, :stage))

    d0 = Timex.today()
    dp1 = Timex.shift(d0, days: 1)

    c1 = insert(:contest, host: h, start_date: d0, end_date: dp1, timetables_public: true)
    c2 = insert(:contest, host: h, start_date: dp1, end_date: dp1, timetables_public: true)
    insert_performance(c1, stage: s)
    insert_performance(c2, stage: s)

    query = "query { contests: featuredContests { id } }"
    conn = get(conn, "/graphql", query: query)

    assert json_response(conn, 200) == %{"data" => %{"contests" => [%{"id" => "#{c1.id}"}]}}
  end
end
