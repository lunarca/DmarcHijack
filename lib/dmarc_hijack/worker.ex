defmodule DmarcHijack.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:process_dmarc, domain}, _from, state) do
    {:reply, Dmarc.process_dmarc_policy(domain), state}
  end
end
