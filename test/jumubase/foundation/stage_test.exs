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

    test "is invalid with broken coordinates" do
      for {lat, lon} <- [{nil, 50.0}, {10.0, nil}] do
        params = params_for(:stage, latitude: lat, longitude: lon)
        changeset = Stage.changeset(%Stage{}, params)
        refute changeset.valid?
      end
    end

    test "is valid with complete coordinates" do
      params = params_for(:stage, latitude: 10.0, longitude: 50.0)
      changeset = Stage.changeset(%Stage{}, params)
      assert changeset.valid?
    end
  end
end
