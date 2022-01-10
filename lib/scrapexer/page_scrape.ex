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

  def parse_item(url) do
    {:ok, parsed} = html_as_string(url)
    |> Floki.parse_document()
    parsed
  end

  def base_url(url) do
    Regex.run(~r/^.+?[^\/:](?=[?\/]|$)/, url)
    |> hd()
  end

  def is_a_link?(string) do
    Regex.match?(~r/http/, string) or Regex.match?(~r/.html/, string)
  end

  def complete_incomplete_link(link,domain) do
    if not Regex.match?(~r/https?/,link) do
      case String.at(link,0) do
        "/" -> domain <> link
        "#" -> domain <> "/" <> String.slice(link,1..-1)
        _ -> domain <> "/" <> link
      end
      else
        link
     end
  end

  def links_from_html(parsed_doc) do
    parsed_doc
    |> Floki.attribute("a","href")
    end


  def domain_links_from_html(parsed_doc, domain) do
    parsed_doc
    |> links_from_html
    |> Enum.map(&(complete_incomplete_link(&1,domain) ))
    |> Enum.filter(&(Regex.match?(~r/#{domain}/,&1) ))
    |> Enum.uniq
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

  def links_from_url(url) do
    url
    |> parse_item
    |> links_from_html
  end

  def multi_filter_out(parsed_doc,selectors) do
    case selectors do
      [] -> parsed_doc
      [first | rest] -> multi_filter_out(Floki.filter_out(parsed_doc, first), rest)
    end
  end

  def text_from_parsed(parsed) do
    parsed
    |> Floki.text(deep: true)
  end

  def text_from_url(url) do
    url
    |> parse_item
    |> text_from_parsed
  end

end
