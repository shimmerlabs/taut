defmodule Taut.Message do
  use Taut.Model

  schema "taut_messages" do
    field :content, :string
    field :user_id, :binary_id
    field :room_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
