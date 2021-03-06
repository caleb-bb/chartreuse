defmodule PageScrapeTest do
  import PageScrape
  use ExUnit.Case

  describe "linkes_from_html/1" do
    test "links_from_html" do
      {:ok, collected_links} = File.read("test/resources/page_scrape/collected_links")

      expected_links = String.split(collected_links,"\n")

      {:ok, html_links} = File.read("test/resources/page_scrape/main.html")
      actual_links = links_from_html(html_links)

      assert expected_links == actual_links
    end
  end


  test "domain_links_from_html" do

    {:ok, collected_links} = File.read("test/resources/page_scrape/collected_domain_links")
    expected_links = String.split(collected_links,"\n")
    |> Enum.drop(1)


    {:ok, html_links} = File.read("test/resources/page_scrape/main.html")
    domain = "https://www.hopelutheransunbury.org"
    actual_links = domain_links_from_html(html_links,domain)

    assert expected_links == actual_links
  end

  test "base_url" do
    urls = [
      "https://www.youtube.com/watch?v=EM7aPIpjvUw",
      "youtube.com/watch?v=EM7aPIpjvUw",
      "https://www.theguardian.com/sport/2022/jan/06/quarterback-trades-nfl-football-2022-offseason-russell-wilson-aaron-rodgers"
    ]

    expected_output = [
      "https://www.youtube.com",
      "youtube.com",
      "https://www.theguardian.com"
    ]

    actual_output = Enum.map(urls,&(base_url(&1)))

   assert actual_output == expected_output
  end

  test "incomplete_internal?" do
    internals? = ["resources.html",
                  "/resources/what.html",
                  "#someotherlink.html",
                  "www.notinternal.com",
                  "www.notinternal.com/stuff.html",
                  "https://otherplace.com",
                  "https://www.otherplace.com",
                  "https://otherplace.com/thing.html",
                  "https://www.otherplace.com/thing.html",
                  "otherplace.com",
                  "ptherplace.com/thing.html",
                  "https://www.not-incomplete.com/internal.html"
    ]
    expected_truth_vals = [true,true,true,false,false,false,false,false,false,false,false,false]
    actual_truth_vals = Enum.map(internals?,&incomplete_internal?(&1))

    assert expected_truth_vals == actual_truth_vals
  end

  test "complete_incomplete_link" do
    incompletes? = ["https://www.something.com",
                    "/thing.html",
                    "otherthing.html"]

    expected_completes = ["https://www.something.com",
                    "https://www.something.com/thing.html",
                    "https://www.something.com/otherthing.html"]

    actual_completes = Enum.map(incompletes?,&(complete_incomplete_link(&1,"https://www.something.com")))

    assert actual_completes == expected_completes
  end

 end
