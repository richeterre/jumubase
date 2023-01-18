defmodule Jumubase.StageTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.Stage

  describe "changeset" do
    test "is valid with valid attributes" do
      params = params_for(:stage)
      changeset = Stage.changeset(%Stage{}, params)
      assert changeset.valid?
    end

    test "is invalid without a name" do
      params = params_for(:stage, name: "")
      changeset = Stage.changeset(%Stage{}, params)
      refute changeset.valid?
    end
  end
end
