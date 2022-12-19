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


  post "/v1/insert/value/" do
    CacheManager.insert_value("name","rocha")
    request = HandleRequest.extract_payload(conn)
    account = %{account_number: "73216154", balance: 15000000}
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end

  get "/get/value/:id" do
    account = %{account_number: "73216154", balance: 15000000, id: id}
     {:ok, result} = CacheManager.get_value("name")
    IO.inspect("The id is #{id}")
    IO.inspect("consultado el valor para la llave #{id} valor : #{result}")
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end

  delete "/delete/value/:id" do
    account = %{account_number: "73216154", balance: 15000000, id: id}
     {:ok, result} = CacheManager.get_value("name")
    IO.inspect("The id is #{id}")
    IO.inspect("consultado el valor para la llave #{id} valor : #{result}")
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end

  delete "/clear/cache/" do
    account = %{account_number: "73216154", balance: 15000000, id: id}
     {:ok, result} = CacheManager.get_value("name")
    IO.inspect("The id is #{id}")
    IO.inspect("consultado el valor para la llave #{id} valor : #{result}")
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end

  match _ do
    Logger.error("Recurso no encontrado")
    {body, conn} = HandleError.handle_error({:error, :not_found}, conn)
    HandleResponse.build_response(body, conn)
  end



end
