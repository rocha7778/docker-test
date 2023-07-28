defmodule App.Requests.Registration do
  use Request.Validator

  # Get the validation rules that apply to the incoming request.
  @impl Request.Validator
  def rules(_) do
    [
      email: ~w[required email]a,
      first_name: ~w[required string]a,
      last_name: ~w[required string]a,
      password: [:required, :string, {:min, 8}, :confirmed]
    ]
  end

  # Determine if the user is authorized to make this request.
  @impl Request.Validator
  def authorize(_), do: true
end
