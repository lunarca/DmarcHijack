defmodule DmarcHijack.Application do
  use Application

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: DmarcHijack.Worker,
      size: 16,
      max_overflow: 5
    ]
  end

  @impl true
  def start(_type, _args) do
    children = [
      DmarcHijack.ResultsBucket,
      :poolboy.child_spec(:worker, poolboy_config())

    ]

    opts = [strategy: :one_for_one, name: DmarcHijack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
