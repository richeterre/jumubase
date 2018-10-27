defmodule Jumubase.AccountsTest do
  use Jumubase.DataCase
  alias Jumubase.Accounts
  alias Jumubase.Accounts.User

  test "list_users/0 returns all users" do
    user = insert(:user)
    assert Accounts.list_users() == [user]
  end

  test "load_hosts/1 loads associated hosts into a single user or list of users" do
    user = insert(:user)
    refute Ecto.assoc_loaded?(user.hosts)

    single_user = Accounts.load_hosts(user)
    assert Ecto.assoc_loaded?(single_user.hosts)
    [list_user] = Accounts.load_hosts([user])
    assert Ecto.assoc_loaded?(list_user.hosts)
  end

  test "get/1 returns the user with given id" do
    user = insert(:user)
    assert Accounts.get(user.id) == user
  end

  test "get!/1 returns the user with given id" do
    user = insert(:user)
    assert Accounts.get!(user.id) == user
  end

  test "get!/1 returns an error for an unknown user id" do
    assert_raise Ecto.NoResultsError, fn -> Accounts.get!(1) end
  end

  test "get_by/1 returns a user by their email" do
    email = "abc@de.fi"
    user = insert(:user, email: email)
    assert Accounts.get_by(%{"email" => email}) == user
  end

  test "create_user/1 with valid data creates a user" do
    valid_attrs = params_for(:user, password: "password")
    assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
    assert user.email == valid_attrs[:email]
    assert user.given_name == valid_attrs[:given_name]
    assert user.family_name == valid_attrs[:family_name]
    assert user.role == valid_attrs[:role]
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{})
  end

  test "update_user/2 with valid data updates the user" do
    [h1, h2, h3] = insert_list(3, :host)
    user = insert(:user, email: "a@xyz.org", given_name: "A", family_name: "B", role: "local-organizer", hosts: [h1, h2])
    update_attrs = %{email: "b@xyz.org", given_name: "X", family_name: "Y", role: "global-organizer", host_ids: [h2.id, h3.id]}

    assert {:ok, user} = Accounts.update_user(user, update_attrs)
    assert %User{} = user
    assert user.email == update_attrs[:email]
    assert user.given_name == update_attrs[:given_name]
    assert user.family_name == update_attrs[:family_name]
    assert user.role == update_attrs[:role]
    assert user.hosts == [h2, h3]
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = insert(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{email: nil})
    assert user == Accounts.get(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = insert(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    refute Accounts.get(user.id)
  end

  test "change_user/1 returns a user changeset" do
    user = insert(:user)
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end

  test "update_password/2 changes the stored hash" do
    %{password_hash: stored_hash} = user = insert(:user)
    attrs = %{password: "CN8W6kpb"}
    {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
    assert hash != stored_hash
  end

  test "update_password/2 with weak password fails" do
    user = insert(:user)
    attrs = %{password: "pass"}
    assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
  end
end
