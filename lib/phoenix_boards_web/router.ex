defmodule PhoenixBoardsWeb.Router do
  use PhoenixBoardsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug PhoenixBoardsWeb.APIAuthPlug, otp_app: :phoenix_boards
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: PhoenixBoardsWeb.APIAuthErrorHandler
  end

  scope "/v1", PhoenixBoardsWeb.V1, as: :api_v1 do
    pipe_through :api

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    get "/confirmation/:id", ConfirmationController, :confirm
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  scope "/v1", PhoenixBoardsWeb.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]

    # Protected endpoints will go here
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phoenix_boards, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhoenixBoardsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
