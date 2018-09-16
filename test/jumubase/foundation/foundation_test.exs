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
end
