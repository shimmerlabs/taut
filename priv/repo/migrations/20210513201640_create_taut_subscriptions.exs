defmodule Taut.Repo.Migrations.CreateTautSubscriptions do
  use Ecto.Migration

  def change do
    create table(:taut_subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:taut_rooms, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:taut_users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:taut_subscriptions, [:room_id])
    create index(:taut_subscriptions, [:user_id])
  end
end
