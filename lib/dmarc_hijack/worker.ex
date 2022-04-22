# require Logger

defmodule DmarcHijack.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:fetch_process_dmarc, domain}, _from, state) do
    # Logger.info("Processing DMARC record for #{domain}")
    results = Dmarc.process_dmarc_policy(domain)
    # Logger.info("Found results for #{domain}: #{results}")

    {:reply, results, state}
  end
end
