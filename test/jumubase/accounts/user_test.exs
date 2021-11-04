defmodule Jumubase.UserTest do
  use Jumubase.DataCase
  alias Jumubase.Accounts.User

  describe "create_changeset/2" do
    test "is valid with valid attributes" do
      params = valid_user_params()
      changeset = User.create_changeset(%User{}, params)
      assert changeset.valid?
    end

    test "is invalid without a given name" do
      params = %{valid_user_params() | given_name: nil}
      changeset = User.create_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "is invalid without a family name" do
      params = %{valid_user_params() | family_name: nil}
      changeset = User.create_changeset(%User{}, params)
      refute changeset.valid?
    end

    test "is invalid with an invalid email" do
      with_spaces = "a @b.c"
      no_at_sign = "ab.c"
      too_long = String.duplicate("a", 157) <> "@b.c"

      for email <- [nil, with_spaces, no_at_sign, too_long] do
        params = %{valid_user_params() | email: email}
        changeset = User.create_changeset(%User{}, params)
        refute changeset.valid?
      end
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:user)
      params = %{valid_user_params() | email: email}
      changeset = User.create_changeset(%User{}, params)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "is invalid with an invalid password" do
      too_short = String.duplicate("x", 7)
      too_long = String.duplicate("x", 73)

      for pwd <- [nil, too_short, too_long] do
        params = %{valid_user_params() | password: pwd}
        changeset = User.create_changeset(%User{}, params)
        refute changeset.valid?
      end
    end

    test "hashes and clears the password for valid attributes" do
      params = valid_user_params()
      changeset = User.create_changeset(%User{}, params)
      assert is_binary(changeset.changes.hashed_password)
      refute Map.has_key?(changeset.changes, :password)
    end

    test "does not hash and clear the password for invalid attributes" do
      params = %{valid_user_params() | given_name: nil}
      changeset = User.create_changeset(%User{}, params)
      refute Map.has_key?(changeset.changes, :hashed_password)
      assert is_binary(changeset.changes.password)
    end

    test "is invalid with an invalid role" do
      for role <- [nil, "unknown"] do
        params = %{valid_user_params() | role: role}
        changeset = User.create_changeset(%User{}, params)
        refute changeset.valid?
      end
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  # Private helpers

  defp valid_user_params do
    params_for(:user, password: "password")
  end
end
