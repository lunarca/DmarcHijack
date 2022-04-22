defmodule Mix.Tasks.Single do
  @timeout 60000
  @moduledoc "Check the DMARC record for a single domain"
  @shortdoc "Check the DMARC record for a single domain"

  @requirements ["app.start"]

  alias DmarcHijack.ResultsBucket

  use Mix.Task

  @impl Mix.Task
  def run([domain]) when domain != "" do
    IO.puts("Searching for DMARC misconfiguration for #{domain}")

    {:ok, {response_code, result}} = setup_task(domain)
    |> await_and_inspect()
    |> log_in_agent()
    |> ResultsBucket.get()

    handle_response(response_code, result)
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

  defp log_in_agent({domain, {response_code, result}}) do
    ResultsBucket.add(domain, response_code, result)
    domain
  end

  defp handle_response(:ok, :none), do: IO.puts "Vulnerable: policy set to None"
  defp handle_response(:error, reason), do: IO.puts("Not vulnerable: #{reason}")
  defp handle_response(:ok, policy), do: IO.puts("Not Vulnerable: Policy set to #{policy}")




end
