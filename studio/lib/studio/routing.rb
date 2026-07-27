# frozen_string_literal: true

def examples_for(category_slug)
  gallery_examples.select { |item| item[:category] == category_slug }
end

def example(slug)
  gallery_examples.find { |item| item[:slug] == slug } ||
    EXAMPLES.find { |item| item[:slug] == slug } ||
    EXAMPLES.first
end

def studio_go(page, route)
  page.go(route)
end

def build_studio_view_for_route(page, route)
  current_route = page.route
  page.route = route
  yield
ensure
  page.route = current_route
end

def gallery_grid_route?(route)
  route.to_s.include?("view=grid")
end

def render(page, flush: false)
  route = route_path(page)
  route = "/gallery" if route.empty? || %w[/ /studio].include?(route)
  page.title = "ruflet_studio"
  apply_studio_theme(page)

  base = respond_to?(:studio_base_view, true) ? studio_base_view : nil
  root_gallery = build_studio_view_for_route(page, "/studio") { gallery_view(page) }
  root_gallery.props["route"] = "/studio"
  stack = [base, root_gallery].compact

  case route
  when "/gallery"
    if !show_categories_menu?(page) && gallery_grid_route?(page.route)
      grid = gallery_view(page, back: "/gallery")
      grid.props["route"] = page.route
      stack << grid
    elsif show_categories_menu?(page)
      root_gallery = gallery_view(page)
      root_gallery.props["route"] = page.route
      stack = [base, root_gallery].compact
    end
  when %r{\A/gallery/([^/]+)/example/([^/]+)}
    category = Regexp.last_match(1)
    example_slug = Regexp.last_match(2)
    origin = page.query["from"].to_s
    back = origin.empty? ? "/gallery/#{category}" : origin
    if gallery_grid_route?(origin)
      grid = build_studio_view_for_route(page, origin) { gallery_view(page, back: "/gallery") }
      grid.props["route"] = origin
      stack << grid
    else
      category_screen = category_view(page, category)
      category_screen.props["route"] = "/gallery/#{category}"
      stack << category_screen
    end
    stack << editor_view(page, example(example_slug), back_route: back)
  when %r{\A/gallery/([^/]+)}
    stack << category_view(page, Regexp.last_match(1))
  when %r{\A/settings/([^/]+)}
    stack << settings_view(page, Regexp.last_match(1))
  end

  page.views = stack
  page.update if flush
end
