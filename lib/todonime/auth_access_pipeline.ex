defmodule Todonime.AuthAccessPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :todonime,
    module: Todonime.Guardian,
    error_handler: Todonime.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end