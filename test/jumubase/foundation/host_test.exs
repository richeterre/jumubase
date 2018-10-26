defmodule Jumubase.HostTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.Host

  describe "changeset" do
    test "is valid with valid attributes" do
      params = params_for(:host)
      changeset = Host.changeset(%Host{}, params)
      assert changeset.valid?
    end

    test "is invalid without a name" do
      params = params_for(:host, name: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "is invalid without a city" do
      params = params_for(:host, city: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "is invalid without a country code" do
      params = params_for(:host, country_code: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "is invalid without a time zone" do
      params = params_for(:host, time_zone: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "is invalid without a latitude" do
      params = params_for(:host, latitude: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end

    test "is invalid without a longitude" do
      params = params_for(:host, latitude: "")
      changeset = Host.changeset(%Host{}, params)
      refute changeset.valid?
    end
  end
end
