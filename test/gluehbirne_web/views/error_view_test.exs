defmodule MindwendelWeb.ErrorViewTest do
  use MindwendelWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  setup %{conn: conn} do
    # When rendering the error_page.html.eex the connection is necesary, e.g. because of
    # <script defer phx-track-static type="text/javascript" src="<%= Routes.static_path(@conn, "/js/app.js") %>"></script>
    #
    # Although this MindwendelWeb.ConnCase sets the endpoint, is not avail in the tests. As a fix, I needed to set endpoint explicitely
    # See here https://www.munich-made.com/2020/03/20200304220507-testing-custom-errorview-in-phoenix/
    %{conn: conn |> Plug.Conn.put_private(:phoenix_endpoint, MindwendelWeb.Endpoint)}
  end

  test "renders 404.html", %{conn: conn} do
    assert render_to_string(MindwendelWeb.ErrorView, "404.html", %{conn: conn, status: 404}) =~
             "Try again from home"
  end

  test "renders 500.html", %{conn: conn} do
    assert render_to_string(MindwendelWeb.ErrorView, "500.html", %{conn: conn, status: 404}) =~
             "Try again from home"
  end
end
