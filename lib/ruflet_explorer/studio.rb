# frozen_string_literal: true

require "cgi"

# Ruflet Studio is vendored from:
# /Users/macbookpro/Documents/Izeesoft/RailsApp/ruflet_studio
#
# Load the same source tree as its standalone main.rb, but do not call
# Ruflet.run. Explorer and Studio intentionally share one page and Ruby VM.
require_relative "../../studio/lib/studio/config"
require_relative "../../studio/lib/gallery"
require_relative "../../studio/lib/studio/builtin_examples"
require_relative "../../studio/lib/studio/gallery_catalog"
require_relative "../../studio/lib/studio/preview_runtime"
require_relative "../../studio/lib/studio/routing"
require_relative "../../studio/lib/studio/shell"
require_relative "../../studio/lib/studio/gallery_views"
require_relative "../../studio/lib/studio/editor_views"
require_relative "../../studio/lib/studio/thumbnails"
require_relative "../../studio/lib/studio/preview_builders"
require_relative "../../studio/lib/studio/settings"

module RufletExplorer
  class Studio
    BREAKPOINTS = [700, 760].freeze

    def initialize(page, on_exit:)
      @page = page
      @on_exit = on_exit
      @layout_signature = nil
    end

    def show
      @base_view = @page.views.first
      @page.appbar = nil
      @page.controls = [] unless @page.controls.empty?
      @page.padding = 0
      @page.floating_action_button = fab(
        icon: "hub",
        tooltip: "Back to Ruflet Explorer",
        on_click: ->(_event) { @page.go("/") }
      )
      @page.on_route_change = lambda do |_event|
        if @page.route.to_s.split("?").first == "/"
          @on_exit.call
        else
          render(@page)
        end
      end
      @page.on_resize = ->(_event) { render_after_breakpoint_change }
      @page.on_view_pop = lambda do |_event|
        @page.views.pop
        revealed = @page.views.last
        route = revealed&.props&.fetch("route", nil) || "/"
        @page.go(route)
      end
      @page.on(:platform_brightness_change) do |_event|
        render(@page, flush: true) if studio_theme_mode == "system"
      end
      render(@page)
    end

    private

    def studio_base_view
      @base_view
    end

    def render_after_breakpoint_change
      signature = BREAKPOINTS.map { |breakpoint| @page.width.to_f >= breakpoint }
      return if signature == @layout_signature

      @layout_signature = signature
      render(@page, flush: true)
    end
  end
end
