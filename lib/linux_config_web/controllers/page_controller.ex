defmodule LinuxConfigWeb.PageController do
  use LinuxConfigWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
