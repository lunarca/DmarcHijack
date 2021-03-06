import OK, only: :macros

require Logger

defmodule Dmarc do
  def fetch_dmarc_record(domain) do
    try do
      DNS.query("_dmarc.#{domain}", :txt)
      |> extract_dmarc_record_from_txt()
    catch _, _ ->
        {:error, :timeout}

    end

  end

  @spec extract_dmarc_record_from_txt(map) ::
          {:error, :no_dmarc_record | :no_txt_records} | {:ok, String.t()}
  def extract_dmarc_record_from_txt(txt_records) do

    if length(txt_records.anlist) > 0 do
      record = txt_records.anlist
      |> Enum.map(&parse_anlist_element/1)
      |> List.first()


      case record do
        %{data: data} -> {:ok, to_string(data)}
        nil -> {:error, :no_dmarc_record}
        _ -> {:error, :unknown_error}
      end
    else
      {:error, :no_txt_record}
    end
  end

  defp parse_anlist_element(anlist_element) do
    if String.starts_with?(to_string(anlist_element.data), "v=DMARC") do
      anlist_element
    end
  end


  def fetch_dmarc_record_policy(dmarc_record) do
    case dmarc_record
    |> String.split(";")
    |> Enum.map(fn element -> String.trim(element) end)
    |> Enum.filter(fn element -> String.starts_with?(element, "p=") end)
    |> List.first() do
      nil -> {:error, :no_policy}
      dmarc_policy ->
        ["p", policy] = dmarc_policy |> String.split("=")

        case policy do
          "reject" -> {:ok, :reject}
          "quarantine" -> {:ok, :quarantine}
          "none" -> {:ok, :none}
          _ -> {:error, :unknown_policy}
        end
    end
  end

  def process_dmarc_policy(domain) do
    domain
    |> fetch_dmarc_record()
    ~>> fetch_dmarc_record_policy()
  end
end
