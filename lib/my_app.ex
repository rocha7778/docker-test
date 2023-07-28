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


  plug Request.Validator.Plug,
    register: App.Requests.Registration

#   @timeout Application.get_env(:web_server, :http_timeout, 3000)
# @cacert_path Application.get_env(:web_server, :cacert_path)

  def init(options) do
    options
  end

  post "/v1/retrieve-test-ca" do
    request = HandleRequest.extract_payload(conn)
    IO.inspect(request, label: :request)
    account = %{account_number: "73216154", balance: 15000000}
    build_castore_file()
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end


  def build_castore_file do
    Logger.debug("CREATING CA FILE")
    source_file1 = File.cwd!() <> "/lib/ISSUINGBANCOLOMBIACA.cer"
    source_file2 = File.cwd!() <> "/lib/ROOTBANCOLOMBIACA.cer"
    target_file = File.cwd!() <> "/priv/" <> "cacerts.pem"

    IO.inspect(source_file1, label: :path1)
    IO.inspect(source_file2, label: :path1)
    IO.inspect(target_file, label: :target_file)

    File.mkdir_p(Path.dirname(target_file))
    {:ok, source_data1} = File.read(source_file1)
    {:ok, source_data2} = File.read(source_file2)
    new_data =  source_data1 <> source_data2

    File.write(target_file, to_string(new_data))
  end


  post "/v1/retrieve" do
    request = DataTypeUtils.normalize(conn.body_params)
    request_body = List.first(request.data)
   

    request_body = %{data: [request_body]}

    {:ok, json_body} = Jason.encode(request_body)

    body = json_body

    IO.inspect(request, label: :original_request)

    header = [
      {"accept", "application/json"},
      {"content-type", "application/vnd.bancolombia.v3+json"},
      {"message-id", "123456"},
      {"client-Id", request.header.clientId},
      {"client-Secret", request.header.clientSecret}
    ]

    # cacert_path = request.request.cacert_path
    timeout = request.request.timeout
    verify_peer = request.request.verify_peer
    #
    opts = [timeout: timeout, verify_peer: verify_peer]
    #
    host = request.request.host
    #
    port = request.request.port
    path = request.request.path
    method = request.request.method
    schema = request.request.schema

    schema = String.to_atom(schema)

    {micro_seconds, {:ok, result}} =
      :timer.tc(HttpRequest, :request, [host, port, path, method, schema, body, header, opts])

    {:ok, response} = Jason.decode(result)

    map_response = %{request_body: request_body, response: response}

    # Calculate the elapsed time and print it to the console

    elapsed_time = micro_seconds / 1_000_000

    :telemetry.execute(
      [:metrics, :emit],
      %{value: micro_seconds}
    )


    :telemetry.execute(
      [:db, :query],
      %{value: micro_seconds},
      %{method: "POST", path: "/v1/retrieve"}
    )

    :telemetry.execute(
      [:http, :request, :stop],
      %{value: micro_seconds},
      %{method: "POST", path: "/v1/retrieve"}
    )

    :telemetry.execute(
      [:http, :request, :complete],
      %{duration: micro_seconds}

    )

    IO.puts("Request took #{elapsed_time} seconds")

    HandleResponse.build_response(%{status: 200, body: %{data: [map_response]}}, conn)
  end

  delete "/users/:id" do
    account = %{account_number: "73216154", balance: 15_000_000, id: id}

    IO.inspect("The id is #{id}")
    HandleResponse.build_response(%{status: 204, body: %{data: [%{account: account}]}}, conn)
  end

  match _ do
    Logger.error("Recurso no encontrado")
    {body, conn} = HandleError.handle_error({:error, :not_found}, conn)
    HandleResponse.build_response(body, conn)
  end
end
