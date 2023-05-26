defmodule PhoenixBoards.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :description, :string
    field :in_character, :boolean, default: false
    field :open, :boolean, default: false
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :description, :in_character, :open])
    |> validate_required([:title, :description, :in_character, :open])
  end
end
