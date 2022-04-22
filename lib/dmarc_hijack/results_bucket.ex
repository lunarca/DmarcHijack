defmodule DmarcHijack.ResultsBucket do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Get the associated value from a domain
  """
  @spec get(String.t()) :: {atom, atom}
  def get(domain) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, domain) end) do
      nil -> {:error, :not_available}
      results -> {:ok, results}
    end
  end

  @doc """
  Return the whole state map
  """
  def getAll() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def add(domain, result, policy) do
    Agent.update(__MODULE__, fn state -> Map.put(state, domain, {result, policy}) end)
  end

end
