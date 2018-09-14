defmodule Jumubase.AccountsTest do
  use Jumubase.DataCase

  alias Jumubase.Factory
  alias Jumubase.Accounts
  alias Jumubase.Accounts.User

  @update_attrs %{email: "xyz@de.fi", first_name: "X Y", last_name: "Z", role: "lw-organizer"}
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, role: nil}

  test "list_users/0 returns all users" do
    user = Factory.insert(:user)
    assert Accounts.list_users() == [user]
  end

  test "get/1 returns the user with given id" do
    user = Factory.insert(:user)
    assert Accounts.get(user.id) == user
  end

  test "get!/1 returns the user with given id" do
    user = Factory.insert(:user)
    assert Accounts.get!(user.id) == user
  end

  test "get!/1 returns an error for an unknown user id" do
    assert_raise Ecto.NoResultsError, fn -> Accounts.get!(1) end
  end

  test "get_by/1 returns a user by their email" do
    email = "abc@de.fi"
    user = Factory.insert(:user, email: email)
    assert Accounts.get_by(%{"email" => email}) == user
  end

  test "create_user/1 with valid data creates a user" do
    valid_attrs = Factory.params_for(:user, password: "password")
    assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
    assert user.email == valid_attrs[:email]
    assert user.first_name == valid_attrs[:first_name]
    assert user.last_name == valid_attrs[:last_name]
    assert user.role == valid_attrs[:role]
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = Factory.insert(:user)
    assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == @update_attrs[:email]
    assert user.first_name == @update_attrs[:first_name]
    assert user.last_name == @update_attrs[:last_name]
    assert user.role == @update_attrs[:role]
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = Factory.insert(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert user == Accounts.get(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = Factory.insert(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    refute Accounts.get(user.id)
  end

  test "change_user/1 returns a user changeset" do
    user = Factory.insert(:user)
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end

  test "update_password/2 changes the stored hash" do
    %{password_hash: stored_hash} = user = Factory.insert(:user)
    attrs = %{password: "CN8W6kpb"}
    {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
    assert hash != stored_hash
  end

  test "update_password/2 with weak password fails" do
    user = Factory.insert(:user)
    attrs = %{password: "pass"}
    assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
  end
end
