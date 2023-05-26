defmodule PhoenixBoardsWeb.MessageControllerTest do
  use PhoenixBoardsWeb.ConnCase

  import PhoenixBoards.BoardsFixtures

  alias PhoenixBoards.Boards.Message

  @open_board_attrs %{
    description: "some description",
    in_character: false,
    open: true,
    title: "some title",
  }
  @closed_board_attrs %{
    description: "some other description",
    in_character: false,
    open: false,
    title: "some other title",
  }

  @create_attrs %{
    from: "some from",
    message: "some message"
  }
  @update_attrs %{
    from: "some updated from",
    message: "some updated message"
  }
  @invalid_attrs %{from: nil, message: nil}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {
      :ok,
      conn: conn,
      open_board_id: post(conn, ~p"/api/boards", board: @open_board_attrs) |> json_response(201)["data"]["id"],
      closed_board_id: post(conn, ~p"/api/boards", board: @closed_board_attrs) |> json_response(201)["data"]["id"]
  }
  end

  describe "index" do
    test "lists all messages for board", %{conn: conn, open_board_id: open_board_id} do
      conn = get(conn, ~p"/api/boards/#{open_board_id}/messages")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create message" do
    test "renders message when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")

      assert %{
               "id" => ^id,
               "from" => "some from",
               "message" => "some message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message" do
    setup [:create_message]

    test "renders message when data is valid", %{conn: conn, message: %Message{id: id} = message} do
      conn = put(conn, ~p"/api/messages/#{message}", message: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")

      assert %{
               "id" => ^id,
               "from" => "some updated from",
               "message" => "some updated message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, message: message} do
      conn = put(conn, ~p"/api/messages/#{message}", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message" do
    setup [:create_message]

    test "deletes chosen message", %{conn: conn, message: message} do
      conn = delete(conn, ~p"/api/messages/#{message}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/messages/#{message}")
      end
    end
  end

  defp create_message(_) do
    message = message_fixture()
    %{message: message}
  end
end
