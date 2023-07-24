defmodule PhoenixBoards.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pow.Context` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test@example.com",
        password: "5uperSecret",
        password_confirmation: "5uperSecret"
      })
      |> Pow.Ecto.Context.create(otp_app: :phoenix_boards)

    user
  end
end
