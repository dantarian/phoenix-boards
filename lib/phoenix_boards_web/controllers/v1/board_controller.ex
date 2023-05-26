defmodule PhoenixBoardsWeb.V1.BoardController do
  use PhoenixBoardsWeb, :controller

  alias PhoenixBoards.Boards
  alias PhoenixBoards.Boards.Board

  action_fallback PhoenixBoardsWeb.FallbackController

  def index(conn, _params) do
    boards = Boards.list_boards()
    render(conn, :index, boards: boards)
  end

  def create(conn, %{"board" => board_params}) do
    with {:ok, %Board{} = board} <- Boards.create_board(board_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/v1/boards/#{board}")
      |> render(:show, board: board)
    end
  end

  def show(conn, %{"id" => id}) do
    board = Boards.get_board!(id)
    render(conn, :show, board: board)
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    board = Boards.get_board!(id)

    with {:ok, %Board{} = board} <- Boards.update_board(board, board_params) do
      render(conn, :show, board: board)
    end
  end

  def delete(conn, %{"id" => id}) do
    board = Boards.get_board!(id)

    with {:ok, %Board{}} <- Boards.delete_board(board) do
      send_resp(conn, :no_content, "")
    end
  end
end
