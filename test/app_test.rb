# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ruflet_explorer"

class RufletExplorerAppTest < Minitest::Test
  def setup
    @sent = []
    @page = Ruflet::Page.new(
      session_id: "explorer-test",
      client_details: {
        "route" => "/",
        "platform" => "android",
        "width" => 390,
        "height" => 844
      },
      sender: ->(action, payload) { @sent << [action, payload] }
    )
    @app = RufletExplorer::App.new
  end

  def test_mounts_a_pure_ruflet_connection_screen
    @app.view(@page)

    assert_equal "Ruflet Explorer", @page.title
    assert_nil @page.appbar
    assert_equal 1, @page.views.size
    assert_equal "View", @page.views.first.to_patch["_c"]
    assert_equal "AppBar", @page.views.first.props["appbar"].to_patch["_c"]
    assert_equal "FloatingActionButton", @page.views.first.props["floating_action_button"].to_patch["_c"]
  end

  def test_studio_fab_opens_bundled_studio_and_can_return_to_explorer
    @app.view(@page)
    @page.go("/studio")

    assert_equal "/studio", @page.route
    assert_equal "ruflet_studio", @page.title
    assert_equal "system", @page.theme_mode
    assert_equal 2, @page.views.size
    assert_equal "/", @page.views.first.props["route"]
    assert_equal "/studio", @page.views.last.props["route"]
    assert_equal "iconbutton", @page.views.last.props["appbar"].props["leading"].type
    assert_equal "FloatingActionButton", @page.floating_action_button.to_patch["_c"]
    refute_includes @page.views.first.to_patch.to_s, "Sign in"

    @page.go("/")

    assert_equal "/", @page.route
    assert_equal "Ruflet Explorer", @page.title
    assert_equal "system", @page.theme_mode
    assert_equal 1, @page.views.size
  end

  def test_native_view_pop_reveals_explorer_instead_of_replacing_it
    @app.view(@page)
    @page.go("/studio")
    pop_handler = @page.instance_variable_get(:@page_event_handlers).fetch("view_pop")

    pop_handler.call(nil)

    assert_equal "/", @page.route
    assert_equal 1, @page.views.size
    assert_equal "Ruflet Explorer", @page.title
  end

  def test_gallery_grid_and_root_pop_as_separate_navigation_levels
    @app.view(@page)
    @page.go("/studio")
    @page.go("/gallery?view=grid")

    assert_equal ["/", "/studio", "/gallery?view=grid"], @page.views.map { |view| view.props["route"] }
    grid_view = @page.views.last
    assert_equal "iconbutton", grid_view.props["appbar"].props["leading"].type
    assert_equal "listview", grid_view.children.first.props["content"].type

    pop_handler = @page.instance_variable_get(:@page_event_handlers).fetch("view_pop")
    pop_handler.call(nil)

    assert_equal "/studio", @page.route
    assert_equal ["/", "/studio"], @page.views.map { |view| view.props["route"] }

    pop_handler.call(nil)

    assert_equal "/", @page.route
    assert_equal ["/"], @page.views.map { |view| view.props["route"] }
  end

  def test_example_opened_from_grid_returns_to_grid_before_gallery_root
    @app.view(@page)
    @page.go("/studio")
    @page.go("/gallery/components/example/counter?from=%2Fgallery%3Fview%3Dgrid")

    assert_equal(
      ["/", "/studio", "/gallery?view=grid", "/gallery/components/example/counter"],
      @page.views.map { |view| view.props["route"] }
    )

    pop_handler = @page.instance_variable_get(:@page_event_handlers).fetch("view_pop")
    pop_handler.call(nil)

    assert_equal "/gallery?view=grid", @page.route
    assert_equal ["/", "/studio", "/gallery?view=grid"], @page.views.map { |view| view.props["route"] }
  end

  def test_studio_appearance_setting_switches_light_dark_and_system_modes
    @app.view(@page)
    @page.go("/studio")
    studio = @app.instance_variable_get(:@studio)

    studio.send(:set_studio_theme, @page, "light")
    assert_equal "light", @page.theme_mode
    assert_equal "#F5F7FB", BG

    studio.send(:set_studio_theme, @page, "dark")
    assert_equal "dark", @page.theme_mode
    assert_equal "#020617", BG

    studio.send(:set_studio_theme, @page, "system")
    assert_equal "system", @page.theme_mode
  end

  def test_studio_about_uses_ruflet_version_for_explorer
    @app.view(@page)
    @page.go("/studio")
    @page.go("/settings/about")

    about_patch = @page.views.last.to_patch.to_s
    assert_includes about_patch, "Ruflet Explorer version #{Ruflet::VERSION}"
    refute_includes about_patch, "Ruflet Studio version"
    refute_includes about_patch, "version 1.0.0"
  end

  def test_studio_navigation_sends_one_view_patch_per_route
    @app.view(@page)

    @sent.clear
    @page.go("/studio")
    assert_equal 1, @sent.count { |action, _payload| action == Ruflet::Protocol::ACTIONS[:patch_control] }

    @sent.clear
    @page.go("/gallery/components")
    assert_equal 1, @sent.count { |action, _payload| action == Ruflet::Protocol::ACTIONS[:patch_control] }
  end

  def test_gallery_catalog_loads_example_sources_only_when_opened
    material = gallery_examples.find { |item| item[:slug] == "material" }

    refute material.key?(:files)
    assert_equal(
      %w[main.rb Gemfile],
      item_files(material).keys
    )
  end

  def test_gallery_gemfile_displays_the_loaded_ruflet_version
    counter = gallery_examples.find { |item| item[:slug] == "counter" }
    gemfile = item_files(counter).fetch("Gemfile")

    assert_includes gemfile, %(gem "ruflet_core", ">= #{Ruflet::VERSION}")
    assert_includes gemfile, %(gem "ruflet_server", ">= #{Ruflet::VERSION}")
    refute_includes gemfile, '#{Ruflet::VERSION}'
    refute_includes gemfile, 'gem "flet_core"'
    refute_includes gemfile, 'gem "flet_server"'
  end

  def test_connect_hands_off_to_nested_ruflet_app_with_all_host_extensions
    @app.view(@page)
    @app.send(:connect_to, "ws://localhost:8550/ws")

    patch = @page.controls.first.to_patch
    assert_nil @page.appbar
    assert_equal "ruflet_app", @page.controls.first.type
    # The client widget is still registered upstream as FletApp.
    assert_equal "FletApp", patch["_c"]
    assert_equal "http://10.0.2.2:8550", patch["url"]
    assert_equal true, patch["expand"]
  end

  def web_page(route)
    Ruflet::Page.new(
      session_id: "explorer-web-test",
      client_details: { "route" => route, "platform" => "macos", "width" => 1200, "height" => 800 },
      sender: ->(action, payload) { @sent << [action, payload] }
    )
  end

  def test_web_client_connects_using_the_url_query_parameter
    page = web_page("/?url=http%3A%2F%2Flocalhost%3A8550")
    app = RufletExplorer::App.new
    app.view(page)

    patch = page.controls.first.to_patch
    assert_empty page.views
    assert_equal "FletApp", patch["_c"]
    assert_equal "http://localhost:8550", patch["url"]
  end

  def test_web_client_without_a_url_query_shows_the_launcher
    page = web_page("/")
    app = RufletExplorer::App.new
    app.view(page)

    assert_equal 1, page.views.size
    assert_empty page.controls
  end

  def test_empty_connect_keeps_launcher_visible_and_marks_url_required
    @app.view(@page)
    launcher = @page.views.first
    url_field = @app.instance_variable_get(:@url_field)

    @app.send(:connect_to, "  ")

    assert_same launcher, @page.views.first
    assert_equal 1, @page.views.size
    assert_empty @page.controls
    assert_equal "Server URL is required.", url_field.props["error"]
  end

  def test_scanner_actions_use_typed_control_and_back_restores_launcher
    @app.view(@page)
    @page.go("/scanner")
    scanner = @app.instance_variable_get(:@scanner)

    assert_instance_of RufletExplorer::QrScannerControl, scanner
    assert_equal ["/", "/scanner"], @page.views.map { |view| view.props["route"] }
    assert_equal false, scanner.props["auto_zoom"]
    assert_equal 0.0, scanner.props["zoom_scale"]
    scanner_appbar = @page.views.last.props["appbar"]

    scanner_appbar.props["actions"][0].emit("click", nil)
    assert_equal "toggle_torch", @sent.last.fetch(1).fetch("name")

    scanner_appbar.props["actions"][1].emit("click", nil)
    assert_equal "switch_camera", @sent.last.fetch(1).fetch("name")

    scanner_appbar.props["leading"].emit("click", nil)
    assert_equal "/", @page.route
    assert_equal ["/"], @page.views.map { |view| view.props["route"] }
  end

  def test_native_scanner_view_pop_restores_launcher
    @app.view(@page)
    @page.go("/scanner")
    pop_handler = @page.instance_variable_get(:@page_event_handlers).fetch("view_pop")

    pop_handler.call(nil)

    assert_equal "/", @page.route
    assert_equal ["/"], @page.views.map { |view| view.props["route"] }
  end

  def test_scanner_detect_event_connects_using_embedded_runtime_event_data
    @app.view(@page)
    @page.go("/scanner")
    scanner = @app.instance_variable_get(:@scanner)
    embedded_event = Struct.new(:data).new(
      {
        "value" => "http://192.168.1.20:8550",
        "barcodes" => [
          {
            "raw_value" => "http://192.168.1.20:8550",
            "format" => "qrCode"
          }
        ]
      }
    )

    scanner.emit("detect", embedded_event)

    assert_equal true, @app.instance_variable_get(:@scan_handled)
    assert_equal 1, @page.controls.size
    assert_equal "FletApp", @page.controls.first.to_patch["_c"]
    assert_equal "http://192.168.1.20:8550", @page.controls.first.props["url"]
  end

  def test_invalid_scanner_result_updates_visible_scanner_message
    @app.view(@page)
    @page.go("/scanner")
    scanner = @app.instance_variable_get(:@scanner)
    scanner_message = @app.instance_variable_get(:@scanner_message)

    scanner.emit(
      "detect",
      Struct.new(:data).new({ "value" => "not a Ruflet URL" })
    )

    assert_equal false, @app.instance_variable_get(:@scan_handled)
    assert_equal(
      "This QR code does not contain a valid Ruflet server URL.",
      scanner_message.props["value"]
    )
  end
end
