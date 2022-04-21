defmodule DmarcHijack.MixProject do
  use Mix.Project

  def project do
    [
      app: :dmarc_hijack,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: DmarcHijack.Worker,
      size: 5,
      max_overflow: 2
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ok, "~> 0.2.0"},
      {:dns, "~> 2.3"},
      {:poolboy, "~> 1.5"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  def start(_type, _args) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: DmarcHijack.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
