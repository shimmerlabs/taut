defmodule Taut.Model do
  @moduledoc """
  Common stuff for all database models.  Can 'use' this and avoid redundant
  redundancies.
  """

  defmacro __using__(opts \\ []) do
    excludes = Keyword.get(opts, :except, []) |> List.wrap()
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      alias Taut.Repo

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      unless :new in unquote(excludes) do
        def new(attrs \\ []) do
          changeset(struct(__MODULE__), Enum.into(attrs, %{}, &(&1)))
        end
      end
    end
  end
end
