defmodule Todonime.Mapper do
  alias Sqlitex.Server, as: Sqlite
  alias Todonime.Exception.{NotFound, SqlException}

  defmacro __using__(opts) do
    table = Keyword.get(opts, :table)
    db_struct = Keyword.get(opts, :struct, nil)

    quote bind_quoted: [table: table, db_struct: db_struct] do
      def get(id) do
        case Sqlite.query(:db, "SELECT * FROM #{unquote(table)} WHERE id = #{id}", into: %{}) do
          {:ok, [result]} -> {:ok, prepare(result)}
          {:ok, []} -> {:error, :not_found}
          {:error, details} -> {:error, details}
        end
      end
    
      def get!(id) do
        case get(id) do
          {:ok, result} -> result
          {:error, :not_found} -> raise NotFound, message: "user ##{id} not found."
          {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}."
        end
      end
    
      def update_by_id!(id, values) do
        update!(%{id: id}, values)
      end
      def update!(%{id: id} = data, values) do
        if Map.has_key?(values, :id), do:
          raise ArgumentError, message: "Cannot update id field."
    
        args = Map.to_list(values)
          |> Enum.map_join(",", fn {k, v} -> "#{k} = '#{v}'" end)
    
        case Sqlitex.Server.query(:db, "UPDATE #{unquote(table)} SET #{args} WHERE id = #{id}") do
          {:ok, _} -> Map.merge(data, values) |> prepare()
          {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
        end
      end
    
      def delete_by_id!(id) do
        delete!(%{id: id})
      end
    
      def delete!(%{id: id}) do
        case Sqlite.query(:db, "DELETE FROM #{unquote(table)} WHERE id = #{id}") do
          {:ok, _} -> :ok
          {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}."
        end
      end

      def create(fields) do
        keys = Map.keys(fields)
          |> Enum.join(",")

        values = Map.values(fields)
          |> Enum.join("','")
          |> (&"'#{&1}'").()

        case Sqlite.query(:db, "INSERT INTO #{unquote(table)}(#{keys}) VALUES(#{values})") do
          {:ok, id} ->
            case get_last() do
              {:ok, data} -> {:ok, data}
              error -> error
            end
          error -> error
        end
      end

      defp get_last() do
        case Sqlite.query(:db, "SELECT last_insert_rowid()") do
          {:ok, [["last_insert_rowid()": id]]} -> get(id)
          {:error, details} -> {:error, details}
        end
      end

      defp prepare(result) do 
        if unquote(db_struct) != nil do
          struct(unquote(db_struct), result)
        else
          result
        end
      end

      defoverridable prepare: 1
    end
  end
end