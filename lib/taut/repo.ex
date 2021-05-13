defmodule Taut.Repo do
  use Ecto.Repo,
    otp_app: :taut,
    adapter: Ecto.Adapters.Postgres
end
