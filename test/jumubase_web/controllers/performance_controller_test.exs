defmodule JumubaseWeb.PerformanceControllerTest do
  use JumubaseWeb.ConnCase
  alias Jumubase.Repo
  alias Jumubase.Showtime.Performance

  test "shows the registration form", %{conn: conn} do
    %{id: id} = insert(:contest)
    conn = get(conn, "/contests/#{id}/performances/new")
    assert html_response(conn, 200) =~ "Register"
  end

  test "lets the user register for a contest", %{conn: conn} do
    cc = insert(:contest_category)
    %{id: id} = cc.contest

    params = %{
      "performance" => %{
        "contest_category_id" => cc.id,
        "appearances" => [
          %{
            "participant_role" => "soloist",
            "instrument" => "piano",
            "participant" => %{
              "given_name" => "A",
              "family_name" => "A",
              "birthdate" => "2004-01-01",
              "email" => "ab@cd.ef",
              "phone" => "1234567",
            }
          }
        ]
      }
    }

    conn = post(conn, "/contests/#{id}/performances", params)

    assert redirected_to(conn) == page_path(conn, :home)
    assert performance = Repo.one(Performance) |> Repo.preload([appearances: :participant])
    assert performance.contest_category_id == cc.id
    assert [%{participant: %{email: "ab@cd.ef"}}] = performance.appearances
  end

  test "redirects to the registration form when user submits invalid data", %{conn: conn} do
    cc = insert(:contest_category)
    %{id: id} = cc.contest

    params = %{
      "performance" => %{
        "contest_category_id" => cc.id,
        "appearances" => []
      }
    }

    conn = post(conn, "/contests/#{id}/performances", params)
    assert html_response(conn, 200) =~ "Register"
    assert Repo.all(Performance) == []
  end
end
