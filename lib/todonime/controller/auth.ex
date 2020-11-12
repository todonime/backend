defmodule Todonime.Controller.Auth do
  alias Todonime.Exception.ClientException

  def internal(conn) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    params = Jason.decode! body

    if Map.has_key?(params, "name") && Map.has_key?(params, "hash") do
      user = 
        case Todonime.Mapper.User.verify_and_get(params["name"], params["hash"]) do
          {:ok, user} -> user
          :invalid -> raise ClientException, message: "Invalid login or password."
        end
      {:ok, token, _full_claims} =  Todonime.Guardian.encode_and_sign(user)

      %{
        token: token,
        user: user
      }
      |> Jason.encode!
      |> (&Plug.Conn.send_resp(conn, 200, &1)).()
    else
      %{message: "the request must contain the name and hash fields"}
      |> Jason.encode!
      |> (&Plug.Conn.send_resp(conn, 400, &1)).()
    end
  end
end