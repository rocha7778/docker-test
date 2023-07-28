defmodule HttpClient do
  @moduledoc """
  This module is in charge to make the http requests
  """
  require Logger

  def request(host, port, path, schema, request_body, method, headers \\ [], opts \\ []) do
    case Mint.HTTP.connect(schema, host, port, options(schema, opts)) do
      {:ok, conn} ->
        {:ok, conn, request_ref} =
          Mint.HTTP.request(
            conn,
            method,
            path,
            headers,
            request_body
          )

        handle_response(conn, request_ref)

      {:error, reason} ->
        Logger.error(
          "Ocurrio un error al consultar la api proveedora #{inspect(path)} | Error: #{inspect(reason)}"
        )

        {:error, :internal_server_error}
    end
  end

  defp options(:http, opts) do
    [transport_opts: [timeout: timeout(opts)]]
  end

  defp options(:https, opts) do
    if verify_peer(opts) do
      [
        transport_opts: [
          verify: :verify_peer,
          cacertfile: cacert_path(opts),
          timeout: timeout(opts)
        ]
      ]
    else
      [transport_opts: [verify: :verify_none, timeout: timeout(opts)]]
    end
  end

  defp verify_peer(opts) do
    Keyword.get(opts, :verify_peer, _default = true)
  end

  defp cacert_path(opts) do
    Keyword.get(opts, :cacert_path, default_path())
  end

  defp default_path do
    File.cwd!() <> "/lib/priv/cacerts.pem"
  end

  defp timeout(opts) do
    Keyword.get(opts, :timeout, _default = 3000)
  end

  defp handle_response(conn, request_ref, body \\ []) do
    {conn, http_status, body, status} =
      receive do
        message ->
          case Mint.HTTP.stream(conn, message) do
            {:ok, conn, responses} ->
              {body, status} = process_response(responses, request_ref, body)

              {conn, :ok, body, status}

            {:error, conn, reason, _responses} ->
              {conn, reason, [], :complete}

            :unknown ->
              {conn, :ok, [], :incomplete}
          end
      end

    if status == :complete do
      Mint.HTTP.close(conn)
      {http_status, body}
    else
      handle_response(conn, request_ref, body)
    end
  end

  defp process_response(responses, request_ref, body) do
    Enum.reduce(
      responses,
      {body, :incomplete},
      fn res, {body, _status} ->
        case res do
          {:status, ^request_ref, _status_code} ->
            {body, :incomplete}

          {:headers, ^request_ref, _headers} ->
            {body, :incomplete}

          {:data, ^request_ref, data} ->
            {[data | body], :incomplete}

          {:done, ^request_ref} ->
            {Enum.reverse(body), :complete}
        end
      end
    )
  end
end
