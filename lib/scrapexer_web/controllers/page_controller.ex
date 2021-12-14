defmodule ScrapexerWeb.PageController do
  use ScrapexerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
