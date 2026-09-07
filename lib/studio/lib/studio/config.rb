# frozen_string_literal: true

STANDALONE_ROOT = File.expand_path("../../standalone_apps", __dir__)
GENERIC_GEMFILE = <<~'GEMFILE'
  source "https://rubygems.org"

  gem "ruflet"
GEMFILE

BG = "#020617"
BAR = "#0f172a"
SURFACE = "#111827"
SURFACE_2 = "#1e293b"
EDITOR_BG = "#0b1120"
PREVIEW_BG = "#f5f6fb"
# Dark backdrop behind the live preview, so light components (e.g. Counter's
# pale card) stay legible instead of washing out on white.
PREVIEW_SURFACE = "#12161a"
TEXT = "#f1f5f9"
MUTED = "#cbd5e1"
BORDER = "#1e293b"
BLUE = "#38bdf8"
PINK = "#cc342d"
RAIL_BLUE = "#082f49"
ORANGE = "#f7a12d"

STUDIO_THEME_CONSTANTS = %i[
  BG BAR SURFACE SURFACE_2 EDITOR_BG PREVIEW_BG PREVIEW_SURFACE
  TEXT MUTED BORDER BLUE RAIL_BLUE
].freeze

STUDIO_THEME_PALETTES = {
  "light" => {
    BG: "#F5F7FB",
    BAR: "#FFFFFF",
    SURFACE: "#FFFFFF",
    SURFACE_2: "#E8EEF8",
    EDITOR_BG: "#F8FAFC",
    PREVIEW_BG: "#F5F6FB",
    PREVIEW_SURFACE: "#E2E8F0",
    TEXT: "#172033",
    MUTED: "#526176",
    BORDER: "#D5DEEA",
    BLUE: "#2563EB",
    RAIL_BLUE: "#DCEBFF"
  },
  "dark" => {
    BG: BG,
    BAR: BAR,
    SURFACE: SURFACE,
    SURFACE_2: SURFACE_2,
    EDITOR_BG: EDITOR_BG,
    PREVIEW_BG: PREVIEW_BG,
    PREVIEW_SURFACE: PREVIEW_SURFACE,
    TEXT: TEXT,
    MUTED: MUTED,
    BORDER: BORDER,
    BLUE: BLUE,
    RAIL_BLUE: RAIL_BLUE
  }
}.freeze

def studio_theme_mode
  @studio_theme_mode ||= "system"
end

def effective_studio_theme(page)
  return studio_theme_mode unless studio_theme_mode == "system"

  brightness =
    page.client_details&.dig("platform_brightness") ||
    page.client_details&.dig(:platform_brightness)
  brightness.to_s.downcase == "dark" ? "dark" : "light"
end

def apply_studio_theme(page)
  palette = STUDIO_THEME_PALETTES.fetch(effective_studio_theme(page))
  palette.each do |name, value|
    Object.send(:remove_const, name) if Object.const_defined?(name, false)
    Object.const_set(name, value)
  end

  page.theme_mode = studio_theme_mode
  page.bgcolor = BG
end

def set_studio_theme(page, mode)
  normalized = mode.to_s.strip.downcase
  return unless STUDIO_THEME_PALETTES.key?(normalized) || normalized == "system"

  @studio_theme_mode = normalized
  GALLERY_PREVIEW.instance_variable_set(:@theme_mode, normalized) if Object.const_defined?(:GALLERY_PREVIEW)
  apply_studio_theme(page)
  render(page, flush: true)
end

CATEGORIES = [
  ["Getting Started", "Build your first Ruflet app", "rocket_launch", "getting-started"],
  ["Layout", "Layout primitives and containers", "view_module", "layout"],
  ["Components", "Individual control demos", "widgets", "components"],
  ["Displays", "Text, images, and information controls", "image", "displays"],
  ["Charts", "Data visualization examples", "show_chart", "charts"],
  ["Animations", "Motion and state transitions", "animation", "animations"],
  ["Effects", "Visual effects and polish", "auto_awesome", "effects"],
  ["Services", "Device and platform integrations", "settings", "services"]
].freeze
