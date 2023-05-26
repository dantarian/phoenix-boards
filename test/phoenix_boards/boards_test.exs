defmodule PhoenixBoards.BoardsTest do
  use PhoenixBoards.DataCase

  alias PhoenixBoards.Boards

  describe "boards" do
    alias PhoenixBoards.Boards.Board

    import PhoenixBoards.BoardsFixtures

    @invalid_attrs %{description: nil, in_character: nil, open: nil, title: nil}

    test "list_boards/0 returns all boards" do
      board = board_fixture()
      assert Boards.list_boards() == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert Boards.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      valid_attrs = %{description: "some description", in_character: true, open: true, title: "some title"}

      assert {:ok, %Board{} = board} = Boards.create_board(valid_attrs)
      assert board.description == "some description"
      assert board.in_character == true
      assert board.open == true
      assert board.title == "some title"
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Boards.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      update_attrs = %{description: "some updated description", in_character: false, open: false, title: "some updated title"}

      assert {:ok, %Board{} = board} = Boards.update_board(board, update_attrs)
      assert board.description == "some updated description"
      assert board.in_character == false
      assert board.open == false
      assert board.title == "some updated title"
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.update_board(board, @invalid_attrs)
      assert board == Boards.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = Boards.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Boards.change_board(board)
    end
  end

  describe "messages" do
    alias PhoenixBoards.Boards.Message

    import PhoenixBoards.BoardsFixtures

    @invalid_attrs %{from: nil, message: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Boards.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Boards.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{from: "some from", message: "some message"}

      assert {:ok, %Message{} = message} = Boards.create_message(valid_attrs)
      assert message.from == "some from"
      assert message.message == "some message"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Boards.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{from: "some updated from", message: "some updated message"}

      assert {:ok, %Message{} = message} = Boards.update_message(message, update_attrs)
      assert message.from == "some updated from"
      assert message.message == "some updated message"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.update_message(message, @invalid_attrs)
      assert message == Boards.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Boards.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Boards.change_message(message)
    end
  end
end
