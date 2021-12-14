defmodule PageScrape do
  @doc """
  Makes HTTP requests and processes HTML into readable form.
  """
  alias HTTPoison

  def html_as_string(url) do
    {:ok, response} = url
    |> HTTPoison.get()
    response.body
  end

  def base_url(url) do
    Regex.run(~r/^.+?[^\/:](?=[?\/]|$)/, url)
    |> hd()
  end

  def init(urls), do: [start_urls: urls]

  def parse_item(url) do
    {:ok, parsed_doc} = html_as_string(url)
    |> Floki.parse_document()
    parsed_doc
  end

  def retrieve_elements(parsed_doc,element) do
    parsed_doc
    |> Floki.find(element)
    |> Floki.text()
  end

  def retrieve_from_url(url, element) do
    url
    |> parse_item
    |> retrieve_elements(element)
  end

end
