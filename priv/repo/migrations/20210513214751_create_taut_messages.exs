defmodule Taut.Repo.Migrations.CreateTautMessages do
  use Ecto.Migration

  def change do
    create table(:taut_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :string, null: false
      add :user_id, references(:taut_users, on_delete: :nilify_all, type: :binary_id)
      add :room_id, references(:taut_rooms, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:taut_messages, [:user_id])
    create index(:taut_messages, [:room_id])
  end
end
