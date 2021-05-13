defmodule Taut do
  @moduledoc """
  Taut keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro add_routes(opts \\ []) do
    quote do
      @taut_scope unquote(Keyword.get(opts, :scope, "/taut"))
      @taut_pipes unquote(Keyword.get(opts, :pipe_through, [:browser]))
      scope @taut_scope, TautWeb, as: :taut do
        pipe_through @taut_pipes
        live "/", PageLive, :index
      end
    end
  end
end
