defmodule PhoenixBoardsWeb.V1.ConfirmationController do
  use PhoenixBoardsWeb, :controller

  plug :load_user_from_confirmation_token

  def confirm(conn, _) do
    PowEmailConfirmation.Plug.confirm_email(conn, %{})
    |> case do
      {:ok, _result, conn} ->
        conn
        |> json(%{data: %{result: "E-mail successfully confirmed."}})

      {:error, _errors, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{
          status: 500,
          message: "internal server error",
        }})
    end
  end

  defp load_user_from_confirmation_token(%{params: %{"id" => token}} = conn, _opts) do
    case PowEmailConfirmation.Plug.load_user_by_token(conn, token) do
      {:error, conn} ->
        conn
        |> put_status(422)
        |> json(
          %{ error: %{
            status: 422,
            message: "invalid or expired token"
          }}
        )
        |> halt()

      {:ok, conn} ->
        conn
    end
  end
end
