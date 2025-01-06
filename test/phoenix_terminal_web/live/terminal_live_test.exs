defmodule PhoenixTerminalWeb.TerminalLiveTest do
  use PhoenixTerminalWeb.ConnCase

  import Phoenix.LiveViewTest
  import PhoenixTerminal.TerminalsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_terminal(_) do
    terminal = terminal_fixture()
    %{terminal: terminal}
  end

  describe "Index" do
    setup [:create_terminal]

    test "lists all terminals", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/terminals")

      assert html =~ "Listing Terminals"
    end

    test "saves new terminal", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/terminals")

      assert index_live |> element("a", "New Terminal") |> render_click() =~
               "New Terminal"

      assert_patch(index_live, ~p"/terminals/new")

      assert index_live
             |> form("#terminal-form", terminal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#terminal-form", terminal: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/terminals")

      html = render(index_live)
      assert html =~ "Terminal created successfully"
    end

    test "updates terminal in listing", %{conn: conn, terminal: terminal} do
      {:ok, index_live, _html} = live(conn, ~p"/terminals")

      assert index_live |> element("#terminals-#{terminal.id} a", "Edit") |> render_click() =~
               "Edit Terminal"

      assert_patch(index_live, ~p"/terminals/#{terminal}/edit")

      assert index_live
             |> form("#terminal-form", terminal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#terminal-form", terminal: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/terminals")

      html = render(index_live)
      assert html =~ "Terminal updated successfully"
    end

    test "deletes terminal in listing", %{conn: conn, terminal: terminal} do
      {:ok, index_live, _html} = live(conn, ~p"/terminals")

      assert index_live |> element("#terminals-#{terminal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#terminals-#{terminal.id}")
    end
  end

  describe "Show" do
    setup [:create_terminal]

    test "displays terminal", %{conn: conn, terminal: terminal} do
      {:ok, _show_live, html} = live(conn, ~p"/terminals/#{terminal}")

      assert html =~ "Show Terminal"
    end

    test "updates terminal within modal", %{conn: conn, terminal: terminal} do
      {:ok, show_live, _html} = live(conn, ~p"/terminals/#{terminal}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Terminal"

      assert_patch(show_live, ~p"/terminals/#{terminal}/show/edit")

      assert show_live
             |> form("#terminal-form", terminal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#terminal-form", terminal: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/terminals/#{terminal}")

      html = render(show_live)
      assert html =~ "Terminal updated successfully"
    end
  end
end
