# frozen_string_literal: true

require "minitest/autorun"

class StandaloneAppsTest < Minitest::Test
  def test_every_gemfile_uses_the_loaded_ruflet_version
    gemfiles = Dir[File.expand_path("../lib/studio/standalone_apps/*/Gemfile", __dir__)]

    refute_empty gemfiles
    gemfiles.each do |gemfile|
      source = File.read(gemfile)
      assert_includes source, 'require "ruflet/version"', gemfile
      assert_includes source, 'gem "ruflet_core", ">= #{Ruflet::VERSION}"', gemfile
      assert_includes source, 'gem "ruflet_server", ">= #{Ruflet::VERSION}"', gemfile
      refute_includes source, "0.0.15", gemfile
    end
  end

  def test_charts_standalone_and_gallery_layouts_are_scrollable
    sources = [
      File.expand_path("../lib/studio/standalone_apps/charts/main.rb", __dir__),
      File.expand_path("../lib/studio/lib/gallery/sections/charts.rb", __dir__)
    ]

    sources.each do |path|
      source = File.read(path)
      assert_match(/column\(\s*\n\s*expand: true,\s*\n\s*scroll: "auto",/, source, path)
    end
  end

  def test_cupertino_controls_are_interactive_in_standalone_and_gallery
    paths = [
      File.expand_path("../lib/studio/standalone_apps/cupertino/main.rb", __dir__),
      File.expand_path("../lib/studio/lib/gallery/sections/controls/cupertino_controls.rb", __dir__)
    ]

    paths.each do |path|
      source = File.read(path)
      assert_operator source.scan("on_change:").size, :>=, 3, path
      assert_includes source, "on_change_end:", path
      %w[Checkbox Switch Slider Radio].each do |control|
        assert_includes source, "#{control}:", path
      end
    end
  end

  def test_studio_code_editor_opens_at_the_start_of_each_file
    source = File.read(
      File.expand_path("../lib/studio/lib/studio/editor_views.rb", __dir__)
    )

    assert_includes source, "selection: { base_offset: 0, extent_offset: 0 }"
  end

  def test_material_controls_are_interactive_and_banner_dismisses_in_place
    paths = [
      File.expand_path("../lib/studio/standalone_apps/material/main.rb", __dir__),
      File.expand_path("../lib/studio/lib/gallery/sections/controls/material_controls.rb", __dir__)
    ]

    paths.each do |path|
      source = File.read(path)
      assert_operator source.scan("on_change:").size, :>=, 2, path
      assert_includes source, "on_change_end:", path
      assert_includes source, "page.update(banner_control, open: false)", path
      assert_includes source, "ListTile pressed", path
      refute_includes source, "page.close_banner(banner_control)", path
    end
  end
end
