# frozen_string_literal: true

def logo_mark
  image(src: "assets/icon.png", width: 28, height: 28)
end

def top_bar(page, title, back: nil, actions: [])
  root_back = %w[/studio /gallery].include?(route_path(page))
  leading_route = back || (root_back ? "/" : nil)
  title_control =
    if back
      text(title, style: { size: 20, weight: "w700", color: TEXT })
    else
      row(spacing: 10, vertical_alignment: "center", children: [
        logo_mark,
        text(title, style: { size: 20, weight: "w700", color: TEXT })
      ])
    end

  app_bar(
    bgcolor: BAR,
    color: TEXT,
    # iOS centers the title by default; keep it left-aligned next to the back button.
    center_title: false,
    leading: leading_route ? icon_button(icon: "arrow_back", on_click: ->(_e) { studio_go(page, leading_route) }) : nil,
    title: title_control,
    actions: actions + [
      icon_button(
        icon: "account_circle",
        tooltip: "Appearance and settings",
        on_click: ->(_e) { studio_go(page, "/settings/system") }
      )
    ]
  )
end

def desktop_shell(page, title, active, body, back: nil)
  control(:view, route: route_path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title, back: back),
    children: [
      row(expand: true, spacing: 0, children: [
        nav_rail(page, active),
        container(width: 1, bgcolor: BORDER),
        container(expand: true, content: body)
      ])
    ])
end

def mobile_shell(page, title, active, body, back: nil)
  control(:view, route: route_path(page), bgcolor: BG, padding: 0, appbar: top_bar(page, title, back: back),
    children: [
      container(expand: true, content: body)
    ])
end

def shell(page, title, active, body, back: nil)
  mobile?(page) ? mobile_shell(page, title, active, body, back: back) : desktop_shell(page, title, active, body, back: back)
end

def nav_rail(page, active)
  container(width: 72, bgcolor: BG, content: column(spacing: 10, children: [
    rail_item(page, "Gallery", "image", "/gallery", active == "gallery")
  ]))
end

def rail_item(page, label, icon_value, route, selected)
  container(padding: { left: 6, right: 6 }, content: column(horizontal_alignment: "center", spacing: 3, children: [
    container(width: 46, height: 36, border_radius: 18, bgcolor: selected ? PINK : BG, alignment: "center",
      on_click: ->(_e) { studio_go(page, route) }, content: icon(icon: icon_value, color: selected ? "#ffffff" : MUTED, size: 22)),
    text(label, style: { color: selected ? TEXT : MUTED, size: 12, weight: selected ? "w700" : "w600" })
  ]))
end


# The category menu is a wide-screen convenience; below this it is hidden so the
# gallery grid gets the full width (the grid shows every example anyway).
