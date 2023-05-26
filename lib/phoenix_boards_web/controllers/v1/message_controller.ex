defmodule PhoenixBoardsWeb.V1.MessageController do
  use PhoenixBoardsWeb, :controller

  alias PhoenixBoards.Boards
  alias PhoenixBoards.Boards.Message

  action_fallback PhoenixBoardsWeb.FallbackController

  def index(conn, _params) do
    messages = Boards.list_messages()
    render(conn, :index, messages: messages)
  end

  def create(conn, %{"board_id" => board_id, "message" => message_params}) do
    with {:ok, %Message{} = message} <- Boards.create_message(message_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/v1/boards/#{board_id}/messages/#{message}")
      |> render(:show, message: message)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Boards.get_message!(id)
    render(conn, :show, message: message)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Boards.get_message!(id)

    with {:ok, %Message{} = message} <- Boards.update_message(message, message_params) do
      render(conn, :show, message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Boards.get_message!(id)

    with {:ok, %Message{}} <- Boards.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
