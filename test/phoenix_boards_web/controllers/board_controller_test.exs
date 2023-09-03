defmodule PhoenixBoardsWeb.BoardControllerTest do
  use PhoenixBoardsWeb.ConnCase

  import PhoenixBoards.BoardsFixtures
  import OpenApiSpex.TestAssertions

  alias PhoenixBoards.Boards.Board
  alias PhoenixBoards.Users.User

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
    user = %User{email: "test@example.com"}
    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :phoenix_boards)

    api_spec =
      :code.priv_dir(:phoenix_boards)
      |> Path.join("schema")
      |> Path.join("boards.yaml")
      |> YamlElixir.read_all_from_file!()
      |> List.first()
      |> OpenApiSpex.OpenApi.Decode.decode()

    {:ok, conn: put_req_header(conn, "accept", "application/json"), api_spec: api_spec}
  end

  describe "index" do
    test "lists boards with no boards", %{conn: conn, api_spec: api_spec} do
      json =
        conn
        |> get(~p"/v1/boards")
        |> json_response(200)

      assert json["data"] == []
      assert_schema(json, "ListBoardsResponse", api_spec)
    end

    test "list boards with one board", %{conn: conn, api_spec: api_spec} do
      %{board: %Board{id: id}} = create_board(%{})

      json =
        conn
        |> get(~p"/v1/boards")
        |> json_response(200)

      assert length(json["data"]) == 1
      assert [%{"id" => ^id}] = json["data"]
      assert_schema(json, "ListBoardsResponse", api_spec)
    end

    test "list with filter", %{conn: conn, api_spec: api_spec} do
      create_board(%{})

      json =
        conn
        |> get(~p"/v1/boards?#{[state: "closed"]}")
        |> json_response(200)

        assert json["data"] == []
        assert_schema(json, "ListBoardsResponse", api_spec)
    end

    test "list boards with multiple pages of boards", %{conn: conn, api_spec: api_spec} do
      Enum.map(1..11, &create_board(%{title: "Board #{&1}"}))

      json =
        conn
        |> get(~p"/v1/boards")
        |> json_response(200)

      assert length(json["data"]) == 10
      assert %{
        "next" => next_link,
      } = json["links"]
      assert_schema(json, "ListBoardsResponse", api_spec)

      json =
        conn
        |> get(next_link)
        |> json_response(200)

      assert length(json["data"]) == 1
      assert %{
        "previous" => previous_link,
      } = json["links"]
      assert_schema(json, "ListBoardsResponse", api_spec)

      json =
        conn
        |> get(previous_link)
        |> json_response(200)

      assert length(json["data"]) == 10
      assert_schema(json, "ListBoardsResponse", api_spec)
    end
  end

  describe "create board" do
    test "renders board when data is valid", %{conn: authed_conn} do
      conn = post(authed_conn, ~p"/v1/boards", board: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(authed_conn, ~p"/v1/boards/#{id}")

      assert %{
        "id" => ^id,
        "type" => "board",
        "attributes" => %{
          "category" => "in_character",
          "description" => "some description",
          "state" => "open",
          "title" => "some title"
        },
      } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: authed_conn} do
      conn = post(authed_conn, ~p"/v1/boards", board: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update board" do
    setup [:create_board]

    test "renders board when data is valid", %{conn: authed_conn, board: %Board{id: id} = board} do
      conn = put(authed_conn, ~p"/v1/boards/#{board}", board: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(authed_conn, ~p"/v1/boards/#{id}")

      assert %{
        "id" => ^id,
        "type" => "board",
        "attributes" => %{
          "category" => "out_of_character",
          "description" => "some updated description",
          "state" => "closed",
          "title" => "some updated title"
        },
      } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: authed_conn, board: board} do
      conn = put(authed_conn, ~p"/v1/boards/#{board}", board: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete board" do
    setup [:create_board]

    test "deletes chosen board", %{conn: authed_conn, board: board} do
      conn = delete(authed_conn, ~p"/v1/boards/#{board}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(authed_conn, ~p"/v1/boards/#{board}")
      end
    end
  end

  defp create_board(attrs) do
    board = board_fixture(attrs)
    %{board: board}
  end
end
