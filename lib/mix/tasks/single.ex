defmodule Mix.Tasks.Single do
  @timeout 60000
  @moduledoc "Check the DMARC record for a single domain"
  @shortdoc "Check the DMARC record for a single domain"

  @requirements ["app.start"]

  use Mix.Task

  @impl Mix.Task
  def run([domain]) do
    setup_task(domain)
    |> await_and_inspect()

  end


  defp setup_task(domain) do
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid ->
          GenServer.call(pid, {:fetch_process_dmarc, domain})
        end,
        @timeout
      )
    end)
  end

  defp await_and_inspect(task), do: task |> Task.await(@timeout) |> IO.inspect()
end
