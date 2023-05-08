defmodule PhoenixBoardsWeb.V1.SessionControllerTest do
  use PhoenixBoardsWeb.ConnCase

  alias PhoenixBoards.{Repo, Users.User}

  @password "secret1234"

  setup do
    confirmed_user =
      %User{}
      |> User.changeset(%{
        email: "confirmed@example.com",
        password: @password,
        password_confirmation: @password,
      })
      |> Repo.insert!()

    PowEmailConfirmation.Ecto.Context.confirm_email(confirmed_user, %{}, otp_app: :phoenix_boards)

    unconfirmed_user =
        %User{}
        |> User.changeset(%{
          email: "unconfirmed@example.com",
          password: @password,
          password_confirmation: @password,
        })
        |> Repo.insert!()

    {:ok, confirmed_user: confirmed_user, unconfirmed_user: unconfirmed_user}
  end

  describe "create/2" do
    @valid_params %{"user" => %{"email" => "confirmed@example.com", "password" => @password}}
    @unconfirmed_params %{"user" => %{"email" => "unconfirmed@example.com", "password" => @password}}
    @invalid_params %{"user" => %{"email" => "confirmed@example.com", "password" => "invalid"}}

    test "with valid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/session", @valid_params)

      assert json = json_response(conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with valid params but unconfirmed user", %{conn: conn} do
      conn = post(conn, ~p"/v1/session", @unconfirmed_params)

      assert json = json_response(conn, 403)
      assert json["error"]["message"] == "You need to confirm your email address before logging in. Check your email."
      assert json["error"]["status"] == 403
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/session", @invalid_params)

      assert json = json_response(conn, 401)
      assert json["error"]["message"] == "Invalid email or password"
      assert json["error"]["status"] == 401
    end
  end

  describe "renew/2" do
    setup %{conn: conn} do
      authed_conn = post(conn, ~p"/v1/session", @valid_params)

      {:ok, renewal_token: authed_conn.private[:api_renewal_token]}
    end

    test "with valid authorization header", %{conn: conn, renewal_token: token} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> post(~p"/v1/session/renew")

      assert json = json_response(conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with invalid authorization header", %{conn: conn} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", "invalid")
        |> post(~p"/v1/session/renew")

      assert json = json_response(conn, 401)
      assert json["error"]["message"] == "Invalid token"
      assert json["error"]["status"] == 401
    end
  end

  describe "delete/2" do
    setup %{conn: conn} do
      authed_conn = post(conn, ~p"/v1/session/", @valid_params)

      {:ok, access_token: authed_conn.private[:api_access_token]}
    end

    test "invalidates", %{conn: conn, access_token: token} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> delete(~p"/v1/session/")

      assert json = json_response(conn, 200)
      assert json["data"] == %{}
    end
  end
end
