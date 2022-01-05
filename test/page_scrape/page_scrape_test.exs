defmodule PageScrapeTest do
  import PageScrape
  use ExUnit.Case

  test "reads correct list of links" do
    {:ok, collected_links} = File.read("test/resources/page_scrape/collected_links")

    expected_links = String.split(collected_links,"\n")


    {:ok, html_links} = File.read("test/resources/page_scrape/main.html")

    actual_links = links_from_html(html_links)
    |> IO.inspect

    assert expected_links == actual_links
  end

end
