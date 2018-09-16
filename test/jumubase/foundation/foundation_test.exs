defmodule Jumubase.FoundationTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation

  test "list_hosts/0 returns all hosts" do
    host = insert(:host)
    assert Foundation.list_hosts() == [host]
  end

  test "list_hosts/1 returns the hosts with the given ids" do
    [_h1, h2, h3] = insert_list(3, :host)
    assert Foundation.list_hosts([h2.id, h3.id]) == [h2, h3]
  end

  test "list_open_contests/0 returns contests the user can sign up for" do
    c1 = insert(:contest, signup_deadline: Timex.today |> Timex.shift(days: 1))
    c2 = insert(:contest, signup_deadline: Timex.today)
    assert Foundation.list_open_contests == [c1, c2]
  end

  test "list_open_contests/0 does not return contests with a past signup deadline" do
    insert(:contest, signup_deadline: Timex.today |> Timex.shift(days: -1))
    assert Foundation.list_open_contests == []
  end

  test "list_open_contests/0 does not return 2nd round contests" do
    insert(:contest, signup_deadline: Timex.today, round: 2)
    assert Foundation.list_open_contests == []
  end
end
