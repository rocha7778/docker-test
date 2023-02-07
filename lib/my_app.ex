defmodule MyApp do
  use Plug.Router
  require Logger

  alias HandleError
  alias HandleResponse
  alias HandleRequest

  alias HttpRequest


  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)


  @timeout Application.get_env(:http_connector, :http_timeout, 3000)
  @cacert_path Application.get_env(:http_connector, :cacert_path)



  def init(options) do
    options
  end



  post "/v1/retrieve" do


    request = DataTypeUtils.normalize(conn.body_params)
    request_body =  List.first(request.data)
    account = %{account_number: "73216154", balance: 15000000}

    request_body = %{data: [request_body]}

    {:ok, json_body} = Jason.encode(request_body)




    body =  json_body

    IO.inspect(request, label: :original_request)

    header = [
                {"accept", "application/json"},
                {"content-type", "application/vnd.bancolombia.v3+json"},
                {"message-id", "123456"},
                {"client-Id", request.header.clientId},
                {"client-Secret", request.header.clientSecret}

             ]


    cacert_path = request.request.cacert_path
    timeout = request.request.timeout
    verify_peer = request.request.verify_peer
#
    opts = [cacert_path:  cacert_path, timeout: timeout, verify_peer: verify_peer]
#
    host = request.request.host
#
    port = request.request.port
    path = request.request.path
    method = request.request.method

    {:ok, result} = HttpRequest.request(host, port, path, method, :https, body, header, opts)

    {:ok, response } = Jason.decode(result)

    map_response = %{request_body: request_body, response: response}

    IO.inspect(result, label: :ocp)
    HandleResponse.build_response(%{status: 200, body: %{data: [map_response]}}, conn)
  end

  delete "/users/:id" do
    account = %{account_number: "73216154", balance: 15000000, id: id}

    IO.inspect("The id is #{id}")
    HandleResponse.build_response(%{status: 204, body: %{data: [%{account: account}]}}, conn)

  end

  match _ do
    Logger.error("Recurso no encontrado")
    {body, conn} = HandleError.handle_error({:error, :not_found}, conn)
    HandleResponse.build_response(body, conn)
  end
end
