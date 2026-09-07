# frozen_string_literal: true

# Run with CRuby, or via RubyRuntime.boot in the embedded mruby harness.
# No Minitest dependency: this regression must also run on the lite runtime.
require_relative '../lib/studio/lib/studio/config' unless Object.const_defined?(:STUDIO_THEME_PALETTES)

class ThemeCheckPage
  attr_accessor :theme_mode, :bgcolor, :client_details
  def initialize
    @client_details = { 'platform_brightness' => 'light' }
  end
end

class ThemeCheckStudio
  attr_reader :redraws
  def initialize
    @redraws = []
  end
  def render(page, flush: false)
    @redraws << [page.theme_mode, page.bgcolor, flush]
  end
end

page = ThemeCheckPage.new
studio = ThemeCheckStudio.new
%w[dark light system].each do |mode|
  studio.send(:set_studio_theme, page, mode)
  raise "Theme #{mode} did not request an immediate redraw" unless studio.redraws.last == [mode, BG, true]
end
raise 'Unexpected redraw count' unless studio.redraws.size == 3

# Exercise the optional preview constant both absent (above) and present.
GALLERY_PREVIEW = Object.new
studio.send(:set_studio_theme, page, 'dark')
raise 'Preview theme did not update' unless GALLERY_PREVIEW.instance_variable_get(:@theme_mode) == 'dark'
page.client_details['platform_brightness'] = 'dark'
studio.send(:set_studio_theme, page, 'system')
raise 'System brightness was ignored' unless page.bgcolor == '#020617'
puts 'Theme changes flush immediately on this Ruby runtime: PASS'
