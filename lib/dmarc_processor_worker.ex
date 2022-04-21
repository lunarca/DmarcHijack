defmodule DmarcProcessorWorker do
  def start_task(domain) do
    Task.async(fn -> Dmarc.process_dmarc_policy(domain) end)
  end
end
