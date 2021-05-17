defmodule Taut.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:taut_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :display_name, :string, required: true
      add :foreign_id, :string, required: true
      add :role, :string, required: true, default: "visitor"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:taut_users, :foreign_id)
  end
end
