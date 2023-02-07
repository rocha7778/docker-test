defmodule Repo do
  use GenServer


  def start_link(name) do
    IO.puts("Starting repo for #{name}.")
    GenServer.start_link(__MODULE__, name, name: Repo)
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end


  @impl true
  def handle_cast({:save_data, data}, state) do
    IO.puts("saving data in database #{data}")
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, data}, _, state) do
    IO.puts("getting data in database")
    {:reply, data, state}
  end

  def child_spec(_) do
    %{
      id: Repo,
      start: {Repo, :start_link, ["mongoDb"]},
      name: __MODULE__
    }
  end

end
