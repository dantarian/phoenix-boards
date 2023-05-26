defmodule PhoenixBoardsWeb.V1.MessageJSON do
  alias PhoenixBoards.Boards.Message

  @doc """
  Renders a list of messages.
  """
  def index(%{messages: messages}) do
    %{data: for(message <- messages, do: data(message))}
  end

  @doc """
  Renders a single message.
  """
  def show(%{message: message}) do
    %{data: data(message)}
  end

  defp data(%Message{} = message) do
    %{
      id: message.id,
      message: message.message,
      from: message.from
    }
  end
end
