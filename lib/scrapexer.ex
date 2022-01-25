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

  def write_path(path,domain,directory) do
    {:ok, ye_olde_pathe} = File.cwd()
    ye_younge_pathe = "#{ye_olde_pathe}/#{directory}/#{domain}/#{path}"
    |> String.trim(".html")
    File.mkdir_p(ye_younge_pathe)
  end

  def write_image(image_tuple,path) do
    File.write(path <> elem(image_tuple,0),elem(image_tuple,1))
  end

  def batch_write_image(url,pattern,path) do
    url
    |> PageScrape.images_from_url(pattern)
    |> Enum.map(&write_image(&1, path))
  end

#  def write_root_directory(url) do
#    url
#    |> PageScrape.base_url
#    |> derive_base_name
#    |> File.mkdir_p
#  end

  def write_path_from_url(url,directory) do
    domain = derive_base_name(url)
    path_list = url
    |> derive_path_list
    |> Enum.join("/")
    |> write_path(domain,directory)
  end

  def write_full_directory(url_list,directory) do
    #write_root_directory(hd(url_list))
    #File.cd(derive_base_name(hd(url_list)))

    Enum.map(url_list, &write_path_from_url(&1,directory))
  end

  def write_html(url) do
    html = url
    |> PageScrape.html_as_string

    text = url
    |> PageScrape.parse_item
    |> PageScrape.text_from_parsed

    treated_url =  String.trim(url, "https://")

    endpoint = treated_url
    |> String.split("/")
    |> List.last

    directory_name = treated_url
    |> String.trim(".html")

    path = Enum.join([derive_base_name(url), "/", directory_name, "/", endpoint])
    image_and_text_path = String.trim(path,".html")

    File.write(path,html)
    File.write(image_and_text_path <> ".txt",text)
    batch_write_image(url, "object-name",image_and_text_path)
  end

  def write_all_urls(url_list) do
    Enum.map(url_list,&write_html(&1))
  end

  def scrape_site(url,directory) do
    list = url
    |> Spider.domain_crawler

    list
    |> write_full_directory(directory)

    File.cd("#{directory}")

    list
    |> write_all_urls

    File.cd("..")
  end

end
