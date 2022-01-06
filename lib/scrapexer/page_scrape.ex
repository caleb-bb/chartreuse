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

  def parse_item(url) do
    {:ok, parsed} = html_as_string(url)
    |> Floki.parse_document()
    parsed
  end

  def is_a_link?(string) do
    Regex.match?(~r/http/, string) or Regex.match?(~r/.html/, string)
  end

  def complete_incomplete_link(link,domain) do
    if Regex.match?(~r/html/,link) and not Regex.match?(~r/http/,link) do
      unless String.at(link,0) == "/", do: domain <> "/" <> link, else: domain <> link
    else
      link
     end
  end

  def site_text(url) do
    url
    |> retrieve_from_url("p")
  end

  def links_from_html(parsed_doc) do
    parsed_doc
    |> Floki.find("a")
    |> Enum.flat_map(&(elem(&1,1)))
    |> Enum.filter(&(elem(&1,0) == "href"))
    |> Enum.map(&(elem(&1,1)))
    end

  def links_from_url(url) do
    url
    |> parse_item
    |> links_from_html
  end

  def domain_links_from_html(parsed_doc, domain) do
    parsed_doc
    |> links_from_html
    |> Enum.map(&(complete_incomplete_link(&1,domain) ))
    |> Enum.filter(&(Regex.match?(~r/#{domain}/,&1) ))
    |> Enum.uniq
    |> Enum.map(&(complete_incomplete_link(&1,domain)))
  end

  def domain_links_from_url(domain,url) do
    url
    |> parse_item
    |> domain_links_from_html(domain)
  end

  def parent_domain_links(url) do
    url
    |> base_url
    |> domain_links_from_url(url)
  end

end
