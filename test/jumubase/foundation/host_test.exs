defmodule Jumubase.HostTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.Host

  describe "changeset" do
    test "with valid attributes" do
      params = params_with_assocs(:host)
      changeset = Host.changeset(%Host{}, params)
      assert changeset.valid?
    end

    test "without a name" do
      params = params_with_assocs(:host, name: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "without a city" do
      params = params_with_assocs(:host, city: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "without a country code" do
      params = params_with_assocs(:host, country_code: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "without a time zone" do
      params = params_with_assocs(:host, time_zone: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end
  end
end
