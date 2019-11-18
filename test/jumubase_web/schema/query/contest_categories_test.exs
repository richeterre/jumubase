defmodule JumubaseWeb.Schema.Query.ContestCategoriesTest do
  use JumubaseWeb.ConnCase, async: true

  test "returns all contest categories for a public contest", %{conn: conn} do
    %{contest_categories: [cc1, cc2]} =
      c = insert(:contest, timetables_public: true) |> with_contest_categories()

    query = """
    query ContestCategories($contestId: ID!) {
      contestCategories(contestId: $contestId) { id }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "contestCategories" => [
                 %{"id" => "#{cc1.id}"},
                 %{"id" => "#{cc2.id}"}
               ]
             }
           }
  end

  test "does not return contest categories for a non-public contest", %{conn: conn} do
    c = insert(:contest, timetables_public: false)
    insert_contest_category(c)

    query = """
    query ContestCategories($contestId: ID!) {
      contestCategories(contestId: $contestId) { id }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert response = json_response(conn, 200)
    assert response["data"] == %{"contestCategories" => nil}
    assert [%{"message" => "No public contest found for this ID"}] = response["errors"]
  end

  test "returns all contest category fields", %{conn: conn} do
    c = insert(:contest, timetables_public: true)

    cc = insert_contest_category(c)
    insert_performance(cc, results_public: true)
    insert_performance(cc, results_public: false)

    query = """
    query ContestCategories($contestId: ID!) {
      contestCategories(contestId: $contestId) {
        id
        name
        publicResultCount
      }
    }
    """

    conn = get(conn, "/graphql", query: query, variables: %{"contestId" => c.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "contestCategories" => [
                 %{
                   "id" => "#{cc.id}",
                   "name" => cc.category.name,
                   "publicResultCount" => 1
                 }
               ]
             }
           }
  end
end
