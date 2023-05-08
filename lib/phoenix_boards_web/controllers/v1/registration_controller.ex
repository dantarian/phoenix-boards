defmodule PhoenixBoardsWeb.V1.RegistrationController do
  use PhoenixBoardsWeb, :controller

  alias Ecto.Changeset
  alias Plug.Conn
  alias PhoenixBoardsWeb.ErrorHelpers

  require Logger

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok, user, conn} ->
        with token <- PowEmailConfirmation.Plug.sign_confirmation_token(conn, user),
             unconfirmed_user <- %{user | email: user.unconfirmed_email || user.email},
             email <-
               PhoenixBoards.Mail.UserConfirmation.confirmation(
                 unconfirmed_user,
                 url(~p"/v1/confirmation/#{token}")
               ),
             :ok <- send_email_async(email) do
          json(conn, %{
            data: %{
              result:
                "An email has been sent to #{unconfirmed_user.email}. Please click the link to confirm that your email address is correct."
            }
          })
        end

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "Couldn't create user", errors: errors}})
    end
  end

  defp send_email_async(email) do
    Task.start(fn ->
      email
      |> PhoenixBoards.Mailer.deliver()
      |> log_warnings()
    end)

    :ok
  end

  defp log_warnings({:error, reason}) do
    Logger.warn("Mailer backend failed with: #{inspect(reason)}")
  end

  defp log_warnings({:ok, response}), do: {:ok, response}
end
