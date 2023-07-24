defmodule PhoenixBoardsWeb.MessageControllerTest do
  use PhoenixBoardsWeb.ConnCase

  import PhoenixBoards.BoardsFixtures
  import PhoenixBoards.UsersFixtures

  alias PhoenixBoards.Boards.{Board, Message}
  alias PhoenixBoards.Users.User

  @create_attrs %{
    from: "some from",
    message: "some message"
  }
  @update_attrs %{
    from: "some updated from",
    message: "some updated message"
  }
  @invalid_attrs %{from: nil, message: nil}

  setup [:create_user, :authorize_conn]

  describe "index" do
    setup [:create_open_board]

    test "lists all messages for empty board", %{conn: authed_conn, board: board} do
      conn = get(authed_conn, ~p"/v1/boards/#{board.id}/messages")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all messages for board with messages", %{
      conn: authed_conn,
      user: user,
      board: board
    } do
      %{message: message1} = create_message(%{user: user, board: board})
      %{message: message2} = create_message(%{user: user, board: board})
      create_message(Map.merge(%{user: user}, create_open_board(%{title: "Other board"})))
      conn = get(authed_conn, ~p"/v1/boards/#{board.id}/messages")
      assert json_response(conn, 200)["data"] == [to_response(message1), to_response(message2)]
    end
  end

  describe "create message" do
    setup [:create_open_board]

    test "renders message when data is valid", %{
      conn: authed_conn,
      board: %Board{id: board_id},
      user: %User{id: user_id}
    } do
      conn = post(authed_conn, ~p"/v1/boards/#{board_id}/messages", message: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{id}")

      assert %{
               "id" => ^id,
               "from" => "some from",
               "message" => "some message",
               "board_id" => ^board_id,
               "user_id" => ^user_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: authed_conn, board: %Board{id: board_id}} do
      conn = post(authed_conn, ~p"/v1/boards/#{board_id}/messages", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message" do
    setup [:create_open_board, :create_message]

    test "renders message when data is valid", %{
      conn: authed_conn,
      board: %Board{id: board_id},
      user: %User{id: user_id},
      message: %Message{id: id} = message
    } do
      conn =
        put(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{message}", message: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{id}")

      assert %{
               "id" => ^id,
               "from" => "some updated from",
               "message" => "some updated message",
               "board_id" => ^board_id,
               "user_id" => ^user_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: authed_conn,
      board: %Board{id: board_id},
      message: message
    } do
      conn =
        put(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{message}", message: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message" do
    setup [:create_open_board, :create_message]

    test "deletes chosen message", %{
      conn: authed_conn,
      board: %Board{id: board_id},
      message: message
    } do
      conn = delete(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{message}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(authed_conn, ~p"/v1/boards/#{board_id}/messages/#{message}")
      end
    end
  end

  defp create_message(%{board: board, user: user}) do
    message = message_fixture(board, user)
    %{message: message}
  end

  defp create_open_board(attrs) do
    board = board_fixture(attrs)
    %{board: board}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp authorize_conn(%{conn: conn, user: user}) do
    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :phoenix_boards)
    conn = put_req_header(conn, "accept", "application/json")
    %{conn: conn}
  end

  defp to_response(%Message{
         id: id,
         from: from,
         message: message,
         board_id: board_id,
         user_id: user_id
       }) do
    %{"id" => id, "from" => from, "message" => message, "board_id" => board_id, "user_id" => user_id}
  end
end
