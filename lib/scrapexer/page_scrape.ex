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

  def generate_random_string do
    random = :rand.uniform(100000000)
    |> Integer.to_string
    |> Base.url_encode64

    random <> "/" <> random

  end

  def extract_header(url,pattern) do
    {:ok, response} = HTTPoison.get(url)
    header = response.headers
    |> Enum.filter(&elem(&1,0) =~ pattern)
    |> Enum.map(&elem(&1,1))

    case header do
      [] -> generate_random_string
      _ -> hd(header)
    end

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

  def incomplete_internal?(string) do
    string
    |> String.trim("https://")
    |> String.trim("http://")
    |> String.trim(".html")
    |> Kernel.=~(~r/\w\.\w/)
    |> Kernel.not

  end

  def complete_incomplete_link(link,domain) do
    if incomplete_internal?(link) do
      case String.at(link,0) do
        "/" -> domain <> link
        "#" -> domain <> "/" <> String.slice(link,1..-1)
        _ -> domain <> "/" <> link
      end
      else
        link
     end
  end

  def sanitize_filename(filename) do
    sanitized = filename
    |> String.split("/")
    |> tl
    |> hd

    case sanitized =~ "undefined" do
     true -> "REMOVE_THIS_ONE"
      _ -> sanitized
    end

  end

  def images_from_url(url,pattern) do
    urls = url
    |> parse_item
    |> Floki.attribute("img","src")
    |> Enum.map(&String.trim(&1,"//"))

    filenames = urls
    |> Enum.map(&extract_header(&1,pattern))
    |> Enum.map(&sanitize_filename(&1))

    pictures = urls
    |> Enum.map(&html_as_string(&1))

    Enum.zip(filenames,pictures)
    |> Enum.filter(&elem(&1,0) != "REMOVE_THIS_ONE")
  end

    def links_from_html(parsed_doc) do
    parsed_doc
    |> Floki.attribute("a","href")
    end

  def pics_from_html(parsed_doc) do
    parsed_doc
    |> Floki.attribute("img","src")
  end


  def domain_links_from_html(parsed_doc, domain) do
    parsed_doc
    |> links_from_html
    |> Enum.map(&complete_incomplete_link(&1,domain ))
    |> Enum.filter(&Regex.match?(~r/#{domain}/,&1 ))
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
    |> Floki.find("p")
    |> Floki.text()
  end

  def text_from_url(url) do
    url
    |> parse_item
    |> text_from_parsed
  end

end
