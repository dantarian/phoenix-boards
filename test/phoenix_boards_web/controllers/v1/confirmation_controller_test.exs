defmodule PhoenixBoardsWeb.V1.ConfirmationControllerTest do
  use PhoenixBoardsWeb.ConnCase

  alias PhoenixBoards.{Repo, Users.User}

  @password "secret1234"

  describe "Confirmation controller" do
    @valid_params %{
      "user" => %{
        "email" => "test@example.com",
        "password" => @password,
        "password_confirmation" => @password
      }
    }

    setup %{conn: conn} do
      conn = post(conn, ~p"/v1/registration", @valid_params)
      user = Repo.one(User)
      email_token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, user)

      {:ok, user: user, token: email_token}
    end

    test "confirms user when token is valid", %{conn: conn, token: token} do
      conn = get(conn, ~p"/v1/confirmation/#{token}")

      assert json = json_response(conn, 200)
      assert json["data"]["result"] == "E-mail successfully confirmed."
    end

    test "errors when token is invalid", %{conn: conn} do
      conn = get(conn, ~p"/v1/confirmation/arbitrary_token")

      assert json = json_response(conn, 422)
      assert json["error"]["message"] == "invalid or expired token"
    end
  end
end
