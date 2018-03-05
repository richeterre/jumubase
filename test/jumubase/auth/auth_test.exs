defmodule Jumubase.AuthTest do
  use Jumubase.DataCase
  alias Jumubase.Factory
  alias Jumubase.Auth

  describe "users" do
    alias Jumubase.Auth.User

    @update_attrs %{email: "xyz@de.fi", first_name: "X Y", last_name: "Z", role: "lw-organizer"}
    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, role: nil}

    test "list_users/0 returns all users" do
      user = Factory.insert(:user)
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = Factory.insert(:user)
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = Factory.params_for(:user)
      assert {:ok, %User{} = user} = Auth.create_user(valid_attrs)
      assert user.email == valid_attrs[:email]
      assert user.first_name == valid_attrs[:first_name]
      assert user.last_name == valid_attrs[:last_name]
      assert user.role == valid_attrs[:role]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = Factory.insert(:user)
      assert {:ok, user} = Auth.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == @update_attrs[:email]
      assert user.first_name == @update_attrs[:first_name]
      assert user.last_name == @update_attrs[:last_name]
      assert user.role == @update_attrs[:role]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = Factory.insert(:user)
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = Factory.insert(:user)
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = Factory.insert(:user)
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end
