defmodule HandleError do
  def handle_error(error, conn) do
    error_body = %{not_found: 404}
    {_, error_code} = error

    cond do
      error_code == :not_found ->
       {%{status: 404, body: error_body}, conn}

      true ->
        {%{status: 500, body: error_body}, conn}
    end
  end
end
