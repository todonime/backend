defmodule Todonime.Task.Anime.Pull do
  require Logger
  alias Todonime.Mapper

  def run do
    {:ok, [%{shikimori_id: max_shiki_id}]} = Sqlitex.Server.query(:db, 
      "SELECT shikimori_id
      FROM animes
      ORDER BY shikimori_id DESC
      LIMIT 1",
      into: %{}
    )

    chunk = Enum.join((max_shiki_id + 1)..(max_shiki_id + 50), ",")
    request("https://shikimori.one/api/animes?limit=50&ids=#{chunk}&kind=tv,movie,ova,ona,special")
    |> Enum.map(fn anime ->
      shikimori_id = anime["id"]
      anime = request("https://shikimori.one/api/animes/#{shikimori_id}")
      IO.inspect anime
      score =
        with {score, _} = Float.parse(anime["score"]),
             do: round(score * 100)
      age_rating = 
        case anime["rating"] do
          "none" -> nil
          rating -> rating
        end

        new_anime = %{
          shikimori_id: shikimori_id,
          name_en: anime["name"],
          name_ru: anime["russian"],
          status: anime["status"],
          kind: anime["kind"],
          rating: score
        }

        new_anime = if age_rating != nil do
          Map.put(new_anime, :age_rating, age_rating)
        else
          new_anime
        end

      db_anime = Mapper.Anime.create!(new_anime)
      %Todonime.Anime{id: anime_id} = db_anime

      Enum.map(1..anime["episodes_aired"], 
        &Mapper.Episode.create!(%{
          number: &1,
          anime_id: anime_id
        }))

      Enum.map(anime["genres"], fn genre ->
        {:ok, [%{id: genre_id}]} = Sqlitex.Server.query(
          :db,
          "SELECT id FROM genres WHERE name = ?",
          bind: [genre["russian"]],
          into: %{}
        )
        Mapper.Genre.link_with_anime(anime_id, genre_id)
      end)
    end)
    Todonime.Task.Anime.SearchCache.run()
  end

  defp request(url), do: request(url, 1)
  defp request(url, attempt) do
    response = HTTPoison.get!(url, [
      "Set-Cookie": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
    ])
    case response.status_code do
      200 -> Jason.decode! response.body
      429 -> 
        if attempt <= 3 do
          Logger.info "HTTP 429: WAIT 5s"
          :timer.sleep(1000)
          request(url, attempt+1)
        else
          raise "Max request attempts exceeded."
        end
      422 -> raise "Client error: #{url}"
      code -> raise "Unknown status code: #{code}"
    end
  end
end