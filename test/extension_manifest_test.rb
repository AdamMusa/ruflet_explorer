# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class ExplorerExtensionManifestTest < Minitest::Test
  def test_bundled_spinkit_gallery_declares_its_renderer_package
    config = YAML.safe_load(File.read(File.expand_path("../ruflet.yaml", __dir__)))
    assert_includes config.fetch("extensions"), "spinkit"
  end
end
