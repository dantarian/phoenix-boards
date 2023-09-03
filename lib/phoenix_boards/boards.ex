defmodule PhoenixBoards.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias PhoenixBoards.Repo

  alias PhoenixBoards.Boards.Board
  alias PhoenixBoards.Users.User

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      %{entries: [%Board{}, ...], metadata: %{...}}

  """
  def list_boards(opts \\ %{})
  def list_boards(%{"after" => _, "before" => _}), do: {:error, "at most one cursor allowed"}

  def list_boards(%{} = opts) when not is_map_key(opts, "state") do
    list_boards(Map.put(opts, "state", "open"))
  end

  def list_boards(%{} = opts) when not is_map_key(opts, "limit") do
    list_boards(Map.put(opts, "limit", 10))
  end

  def list_boards(%{"limit" => limit} = opts) when not is_integer(limit) do
    list_boards(%{opts | "limit" => String.to_integer(limit)})
  end

  def list_boards(%{"state" => state, "limit" => limit, "after" => cursor}) do
    open = state == "open"
    query = from(b in Board, where: b.open == ^open, order_by: [asc: b.id])
    Repo.paginate(query, after: cursor, cursor_fields: [:id], limit: limit)
  end

  def list_boards(%{"state" => state, "limit" => limit, "before" => cursor}) do
    open = state == "open"
    query = from(b in Board, where: b.open == ^open, order_by: [asc: b.id])
    Repo.paginate(query, before: cursor, cursor_fields: [:id], limit: limit)
  end

  def list_boards(%{"state" => state, "limit" => limit}) do
    open = state == "open"
    query = from(b in Board, where: b.open == ^open, order_by: [asc: b.id])
    Repo.paginate(query, cursor_fields: [:id], limit: limit)
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id), do: Repo.get!(Board, id)

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  alias PhoenixBoards.Boards.Message

  @doc """
  Returns the list of messages for a board.

  ## Examples

      iex> list_messages(123)
      [%Message{}, ...]

  """
  def list_messages(board_id) do
    from(m in Message, where: m.board_id == ^board_id)
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%Board{}, %User{}, %{field: value})
      {:ok, %Message{}}

      iex> create_message(%Board{}, %User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(%Board{} = board, %User{} = user, attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:board, board)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
