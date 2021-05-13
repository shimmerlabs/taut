defmodule Taut.UserTest do
  use Taut.DataCase

  test "new_user/1" do
    {:ok, user} = Taut.User.new_user(%{foreign_id: Ecto.UUID.generate(),
                              display_name: "Tester McTesterson"})
    assert Taut.Repo.aggregate(Taut.Subscription, :count) == 1
    assert Taut.Repo.aggregate(Taut.User, :count) == 1
    assert Taut.Repo.aggregate(Taut.Room, :count) == 1

    assert Taut.Repo.preload(user, :rooms).rooms == [Taut.Repo.one(Taut.Room)]
  end
end
