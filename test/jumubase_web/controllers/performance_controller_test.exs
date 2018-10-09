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
            "role" => "soloist",
            "instrument" => "piano",
            "participant" => %{
              "given_name" => "A",
              "family_name" => "A",
              "birthdate" => "2004-01-01",
              "email" => "ab@cd.ef",
              "phone" => "1234567"
            }
          }
        ],
        "pieces" => [
          %{
            "title" => "Title",
            "composer_name" => "Composer",
            "composer_born" => "1900",
            "epoch" => "e",
            "minutes" => 1,
            "seconds" => 23
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

  test "lets the user edit their registration with a valid edit code", %{conn: conn} do
    %{
      id: p_id,
      contest_category: %{contest: %{id: c_id}},
      edit_code: edit_code
    } = insert(:performance)

    conn = get(conn, "/contests/#{c_id}/performances/#{p_id}/edit?code=#{edit_code}")
    assert html_response(conn, 200) =~ "Edit registration"
  end

  test "returns an error when the user tries to edit a registration without an edit code", %{conn: conn} do
    %{id: p_id, contest_category: %{contest: %{id: c_id}}} = insert(:performance)

    assert_error_sent 400, fn ->
      get(conn, "/contests/#{c_id}/performances/#{p_id}/edit")
    end
  end

  test "returns an error when the user tries to edit a registration with an invalid edit code", %{conn: conn} do
    %{id: p_id, contest_category: %{contest: %{id: c_id}}} = insert(:performance)

    assert_error_sent 404, fn ->
      get(conn, "/contests/#{c_id}/performances/#{p_id}/edit?code=unknown")
    end
  end
end
