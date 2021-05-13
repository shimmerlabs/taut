defmodule Taut.Subscription do
  use Taut.Model

  schema "taut_subscriptions" do
    belongs_to :room, Taut.Room
    belongs_to :user, Taut.User

    timestamps()
  end

  @doc false
  def changeset(subscriptions, attrs) do
    subscriptions
    |> cast(attrs, [:room_id, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:room)
  end
end
