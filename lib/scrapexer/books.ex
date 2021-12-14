defmodule Books do

  alias PageScrape

  def search_libgen(title) do
    PageScrape.retrieve_from_url("https//libgen.is/search.php?req=" <> title, "a")
  end
end
