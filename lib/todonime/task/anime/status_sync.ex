defmodule Todonime.Task.Anime.StatusSync do
  require Logger

  def run do
    {:ok, animes} = Sqlitex.Server.query(:db, 
      "SELECT shikimori_id 
      FROM animes 
      WHERE status IN ('anons', 'ongoing')", into: %{}
    )
    ids = Enum.map(animes, &Map.get(&1, :shikimori_id))

    animes = Enum.chunk_every(ids, 50)
    |> Enum.map(&chunk_request(&1))
    |> List.flatten

    Enum.map(animes, fn anime ->
      status = Map.get(anime, "status")
      score = 
        with score = Map.get(anime, "score"),
             {score, _} = Float.parse(score),
        do: round(score * 100)
      shikimori_id = Map.get(anime, "id")
      {:ok, _} = Sqlitex.Server.query(:db, 
        "UPDATE animes 
        SET status='#{status}', rating='#{score}' 
        WHERE shikimori_id=#{shikimori_id}"
      )
      shikimori_id
    end)
    Todonime.Task.Anime.SearchCache.run()
  end

  defp chunk_request(ids), do: chunk_request(ids, 1)
  defp chunk_request(ids, attempt) do
    chunk = Enum.join(ids, ",")

    response = HTTPoison.get!("https://shikimori.one/api/animes?limit=50&ids=#{chunk}")
    case response.status_code do
      200 -> Jason.decode! response.body
      429 -> 
        if attempt <= 3 do
          Logger.info "HTTP 429: WAIT 5s"
          :timer.sleep(1000)
          chunk_request(ids, attempt+1)
        else
          raise "Max request attempts exceeded."
        end
      code -> raise "Unknown status code: #{code}"
    end
  end
end