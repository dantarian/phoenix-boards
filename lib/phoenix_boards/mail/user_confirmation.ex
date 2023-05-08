defmodule PhoenixBoards.Mail.UserConfirmation do
  import Swoosh.Email

  def confirmation(%{email: email}, confirmation_url) do
    new()
    |> to(email)
    |> from("noreply@bathlarp.co.uk")
    |> subject("Welcome to BathLARP!")
    |> text_body("""
    Hello!

    Someone, hopefully you, has used your e-mail address to create an account
    on the BathLARP website. If it was you, please visit the following URL to
    confirm:

    #{confirmation_url}

    If it was not you, please ignore this e-mail, and we won't contact you again.

    Kind regards,
    BathLARP
    """)
  end
end
