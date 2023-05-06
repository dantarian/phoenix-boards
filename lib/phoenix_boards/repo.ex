defmodule PhoenixBoards.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_boards,
    adapter: Ecto.Adapters.Postgres
end
