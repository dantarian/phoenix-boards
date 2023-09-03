defmodule PhoenixBoardsWeb.V1.BoardController do
  use PhoenixBoardsWeb, :controller

  alias PhoenixBoards.Boards
  alias PhoenixBoards.Boards.Board

  action_fallback PhoenixBoardsWeb.FallbackController

  def index(conn, params) do
    base_params = Map.take(params, ["limit", "state"])
    %{entries: boards, metadata: metadata} = Boards.list_boards(params)

    links = %{first: url(~p"/v1/boards?#{base_params}")}
    links = case metadata do
      %Paginator.Page.Metadata{after: cursor} when not is_nil(cursor) ->
        Map.put(links, "next", url(~p"/v1/boards?#{Map.put(base_params, "after", cursor)}"))
      _ -> links
    end
    links = case metadata do
      %Paginator.Page.Metadata{before: cursor} when not is_nil(cursor) ->
        Map.put(links, "previous", url(~p"/v1/boards?#{Map.put(base_params, "before", cursor)}"))
      _ -> links
    end

    render(conn, :index, boards: boards, links: links)
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
