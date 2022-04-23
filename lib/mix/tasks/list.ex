defmodule Mix.Tasks.List do
  @timeout :infinity
  @moduledoc "Check the DMARC record for a list of domains"
  @shortdoc "Check the DMARC record for a list of domains"

  @requirements ["app.start"]

  alias DmarcHijack.ResultsBucket

  require Logger

  use Mix.Task

  @impl Mix.Task
  def run([filepath]) when filepath != "" do
    IO.puts("Searching for DMARC misconfigurations for all domains in #{filepath}")

    file_contents = File.read!(filepath)

    file_contents
    |> String.split("\n")
    |> Enum.map(&setup_task/1)
    |> Enum.map(&await_task/1)

    all_results = ResultsBucket.getAll()
    |> Map.to_list()

    File.write!("all-results.txt", inspect(all_results))

    all_results
    |> Enum.filter(fn {_domain, {_response, policy}} -> policy == :none end)
    |> IO.inspect()

    all_results
  end


  defp setup_task(domain) do
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid ->
          try do
            GenServer.call(pid, {:fetch_process_dmarc, domain})
          catch _, _ ->
            # Handle timeout
            Logger.warning("Probably just got a timeout on #{domain}. Real reason follows:")
            {domain, {:error, :timeout}}
          end
        end,
        @timeout
      )
    end)
  end

  defp await_task(task), do: task |> Task.await(@timeout) |> log_in_agent()

  defp log_in_agent({domain, {response_code, result}}) do
    ResultsBucket.add(domain, response_code, result)
    domain
  end


end
