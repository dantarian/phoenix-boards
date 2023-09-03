defmodule PhoenixBoardsWeb.V1.BoardJSON do
  alias PhoenixBoards.Boards.Board

  @doc """
  Renders a list of boards.
  """
  def index(%{boards: boards, links: links}) do
    %{
      data: for(board <- boards, do: data(board)),
      links: links
    }
  end

  @doc """
  Renders a single board.
  """
  def show(%{board: board}) do
    %{data: data(board)}
  end

  defp data(%Board{} = board) do
    state = if board.open, do: "open", else: "closed"
    category = if board.in_character, do: "in_character", else: "out_of_character"

    %{
      id: board.id,
      type: "board",
      attributes: %{
        title: board.title,
        description: board.description,
        state: state,
        category: category
      }
    }
  end
end
