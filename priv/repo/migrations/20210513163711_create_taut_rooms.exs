defmodule Taut.Repo.Migrations.CreateTautRooms do
  use Ecto.Migration

  def change do
    create table(:taut_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :topic, :string
      add :private, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

  end
end
