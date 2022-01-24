defmodule Scrapexer do
  @moduledoc """
  Scrapexer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def derive_base_name(url) do
    url
    |> PageScrape.base_url
    |> String.split(".")
    |> tl
    |> hd
  end

  def derive_path_list(url) do
    String.trim(url,"https://")
    |> String.split("/")
    #|> tl
  end

  def write_path(path,domain) do
    ye_olde_pathe = "/home/caleb/elixir/scrapexer/#{domain}"
    ye_younge_pathe = "#{ye_olde_pathe}/#{path}"
    |> String.trim(".html")
    File.mkdir_p(ye_younge_pathe)
  end

  def write_image(image_tuple) do
    File.write(elem(image_tuple,0),elem(image_tuple,1))
  end

  def batch_write_image(url,pattern) do
    url
    |> PageScrape.images_from_url(pattern)
    |> Enum.map(&write_image(&1))
  end

#  def write_root_directory(url) do
#    url
#    |> PageScrape.base_url
#    |> derive_base_name
#    |> File.mkdir_p
#  end

  def write_path_from_url(url) do
    domain = derive_base_name(url)
    path_list = url
    |> derive_path_list
    |> Enum.join("/")
    |> write_path(domain)
  end

  def write_full_directory(url_list) do
    #write_root_directory(hd(url_list))
    #File.cd(derive_base_name(hd(url_list)))

    Enum.map(url_list, &write_path_from_url(&1))
  end

  def write_html(url) do
    html = url
    |> PageScrape.html_as_string
    |> IO.inspect

    text = url
    |> PageScrape.parse_item
    |> PageScrape.text_from_parsed

    foo =  String.trim(url, "https://")
    bar =  String.split(foo, "/")
    |> List.last
    bang = foo
    |> String.trim(".html")
    baz = bang <> "/" <> bar
    path = derive_base_name(url) <> "/" <> baz

    IO.inspect(foo)
    IO.inspect(bar)
    IO.inspect(bang)
    IO.inspect(baz)
    IO.inspect(path)

    File.write(path,html)
    File.write(path <> ".txt",text)
  end

end
