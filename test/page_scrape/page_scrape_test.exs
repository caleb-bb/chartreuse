defmodule PageScrapeTest do
  import PageScrape
  use ExUnit.Case

  test "links_from_html" do
    {:ok, collected_links} = File.read("test/resources/page_scrape/collected_links")

    expected_links = String.split(collected_links,"\n")

    {:ok, html_links} = File.read("test/resources/page_scrape/main.html")
    actual_links = links_from_html(html_links)

    assert expected_links == actual_links
  end

  test "domain_links_from_html" do

    {:ok, collected_links} = File.read("test/resources/page_scrape/collected_domain_links")
    expected_links = String.split(collected_links,"\n")
    |> Enum.drop(-1)


    {:ok, html_links} = File.read("test/resources/page_scrape/main.html")
    domain = "https://www.hopelutheransunbury.org"
    actual_links = domain_links_from_html(html_links,domain)

    assert expected_links == actual_links
  end

end
