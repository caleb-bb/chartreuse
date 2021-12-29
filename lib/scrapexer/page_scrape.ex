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

  def retrieve_elements(parsed_doc,selector) do
    parsed_doc
    |> Floki.find(selector)
    #|> Floki.text(sep: ":::::")
  end

  def list_of_elements(parsed_doc,selector) do
    retrieve_elements(parsed_doc, selector)
    |> Floki.text(sep: ":::::")
    |> String.split(~r/:::::/)
  end

  def retrieve_from_url(url, selector) do
    url
    |> parse_item
    |> retrieve_elements(selector)
  end

  def is_a_link?(string) do
    Regex.match?(~r/http/, string) or Regex.match?(~r/.html/, string)
  end

  def complete_incomplete_link(link,domain) do
    if Regex.match?(~r/html/,link) and not Regex.match?(~r/http/,link) do
      domain <> "/" <> link
    else
      link
    end
  end

  def janky_link_collector(url) do
    url
    |> parse_item
    |> Floki.find("a")
    |> Enum.flat_map(fn x -> elem(x,1) end)
    |> Enum.map(fn x -> elem(x,1) end)
    |> Enum.filter(fn x -> is_a_link?(x) end)
  end

  def domain_specific_links(domain,url) do
    url
    |> janky_link_collector
    |> Enum.map(fn x -> complete_incomplete_link(x,domain) end)
    |> Enum.filter(fn x -> Regex.match?(~r/#{domain}/,x) end)
    |> Enum.uniq
  end

  def parent_domain_links(url) do
    url
    |> base_url
    |> domain_specific_links(url)
  end

end
