defmodule MyApp do
  use Plug.Router
  require Logger

  alias HandleError
  alias HandleResponse
  alias HandleRequest
  alias CacheManager

  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  def init(options) do
    options
  end

  post "/v1/redis" do
    request = HandleRequest.extract_payload(conn)
    key = request.redis.key
    value = request.redis.value
    redis = %{key: key, value: value}

    CacheManager.insert_value(key, value)
    HandleResponse.build_response(%{status: 200, body: %{data: [%{redis: redis}]}}, conn)
  end

  get "/v1/redis/:id" do
    case CacheManager.get_value(id) do
      {:ok, result} ->
        redis = %{key: id, value: result}
        HandleResponse.build_response(%{status: 200, body: %{data: [%{redis: redis}]}}, conn)

      {:error, _} ->
        redis = %{key: id, value: "Key not found in cache"}
        HandleResponse.build_response(%{status: 200, body: %{data: [%{redis: redis}]}}, conn)
    end
  end

  delete "/v1/redis/:id" do
    {:ok, result} = CacheManager.delete_value(id)

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(204, "")
  end

  post "/v1/redis/clear-cache" do
    CacheManager.clear_cache()

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(204, "")
  end

  match _ do
    Logger.error("Recurso no encontrado")
    {body, conn} = HandleError.handle_error({:error, :not_found}, conn)
    HandleResponse.build_response(body, conn)
  end
end
