# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ruflet_explorer/url"

class RufletExplorerUrlTest < Minitest::Test
  def test_preserves_http_urls
    assert_equal(
      "http://192.168.1.20:8550",
      RufletExplorer::Url.normalize("http://192.168.1.20:8550")
    )
  end

  def test_converts_websocket_urls_to_page_urls
    assert_equal(
      "https://example.com",
      RufletExplorer::Url.normalize("wss://example.com/ws?token=secret")
    )
  end

  def test_extracts_a_url_from_qr_payload
    assert_equal(
      "https://ruflet.example/connect",
      RufletExplorer::Url.normalize("Open this app: https://ruflet.example/connect")
    )
  end

  def test_maps_android_localhost_to_emulator_host
    assert_equal(
      "http://10.0.2.2:8550",
      RufletExplorer::Url.normalize("localhost:8550", platform: "android")
    )
  end

  def test_rejects_empty_and_invalid_urls
    assert_nil RufletExplorer::Url.normalize("")
    assert_nil RufletExplorer::Url.normalize("https://")
  end
end
