defmodule Mindwendel.AccountsTest do
  use Mindwendel.DataCase
  alias Mindwendel.Factory
  alias Mindwendel.Accounts
  alias Mindwendel.Accounts.User
  alias Mindwendel.Accounts.BrainstormingUser
  alias Mindwendel.Brainstormings.Brainstorming

  setup do
    %{user: Factory.insert!(:user)}
  end

  describe "get_or_create_user" do
    test "get existing user", %{user: existing_user} do
      user = Accounts.get_or_create_user(existing_user.id)

      assert user.id == existing_user.id
      assert Repo.aggregate(User, :count) == 1
    end

    test "create new (non-existing) user" do
      user_id = Ecto.UUID.generate()
      user = Accounts.get_or_create_user(user_id)

      assert user.id == user_id
      assert Repo.aggregate(User, :count) == 2
    end
  end

  describe "get_user" do
    test "returns user when it exists", %{user: existing_user} do
      assert existing_user |> Repo.preload(:brainstormings) ==
               Accounts.get_user(existing_user.id)
    end

    test "returns nil when nil is given" do
      assert is_nil(Accounts.get_user(nil))
    end
  end

  describe "update_user" do
    test "updates the username of a user", %{user: existing_user} do
      {:ok, updated_user} = Accounts.update_user(existing_user, %{username: "test"})
      assert updated_user.username == "test"
    end
  end

  describe "delete_inactive_users" do
    setup do
      old_brainstorming =
        Factory.insert!(:brainstorming, inserted_at: ~N[2021-01-01 10:00:00])
        |> Repo.preload(:users)

      old_user = Factory.insert!(:user, updated_at: ~N[2021-01-01 10:00:00])
      Accounts.merge_brainstorming_user(old_brainstorming, old_user.id)

      %{
        old_user: old_user,
        old_brainstorming: old_brainstorming
      }
    end

    test "removes the old user", %{old_user: old_user} do
      Accounts.delete_inactive_users()

      refute Repo.exists?(from u in User, where: u.id == ^old_user.id)
    end

    test "does not remove new users", %{user: user} do
      assert Repo.exists?(from u in User, where: u.id == ^user.id)
    end

    test "removes the old brainstorming users", %{old_user: old_user} do
      Accounts.delete_inactive_users()
      refute Repo.exists?(from b_user in BrainstormingUser, where: b_user.user_id == ^old_user.id)
    end

    test "does not delete the brainstorming", %{old_brainstorming: old_brainstorming} do
      Accounts.delete_inactive_users()
      assert Repo.exists?(from b in Brainstorming, where: b.id == ^old_brainstorming.id)
    end
  end
end
