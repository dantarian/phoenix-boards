defmodule PhoenixBoards.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixBoards.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        description: "some description",
        in_character: true,
        open: true,
        title: "some title"
      })
      |> PhoenixBoards.Boards.create_board()

    board
  end

  @doc """
  Generate a message.
  """
  def message_fixture(board, user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        from: "some from",
        message: "some message"
      })

    {:ok, message} = PhoenixBoards.Boards.create_message(board, user, attrs)

    message
  end
end
