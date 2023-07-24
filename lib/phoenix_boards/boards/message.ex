defmodule PhoenixBoards.Boards.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :from, :string
    field :message, :string

    belongs_to :user, PhoenixBoards.Users.User
    belongs_to :board, PhoenixBoards.Boards.Board

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :from])
    |> validate_required([:message, :from])
  end
end
