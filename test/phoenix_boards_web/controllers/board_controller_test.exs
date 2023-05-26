defmodule PhoenixBoardsWeb.BoardControllerTest do
  use PhoenixBoardsWeb.ConnCase

  import PhoenixBoards.BoardsFixtures

  alias PhoenixBoards.Boards.Board

  @create_attrs %{
    description: "some description",
    in_character: true,
    open: true,
    title: "some title"
  }
  @update_attrs %{
    description: "some updated description",
    in_character: false,
    open: false,
    title: "some updated title"
  }
  @invalid_attrs %{description: nil, in_character: nil, open: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all boards", %{conn: conn} do
      conn = get(conn, ~p"/api/boards")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create board" do
    test "renders board when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/boards", board: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/boards/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "in_character" => true,
               "open" => true,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/boards", board: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update board" do
    setup [:create_board]

    test "renders board when data is valid", %{conn: conn, board: %Board{id: id} = board} do
      conn = put(conn, ~p"/api/boards/#{board}", board: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/boards/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "in_character" => false,
               "open" => false,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, board: board} do
      conn = put(conn, ~p"/api/boards/#{board}", board: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete board" do
    setup [:create_board]

    test "deletes chosen board", %{conn: conn, board: board} do
      conn = delete(conn, ~p"/api/boards/#{board}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/boards/#{board}")
      end
    end
  end

  defp create_board(_) do
    board = board_fixture()
    %{board: board}
  end
end
