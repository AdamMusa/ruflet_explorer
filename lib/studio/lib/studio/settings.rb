# frozen_string_literal: true

def settings_view(page, tab)
  tabs = {
    "system" => ["Appearance", system_settings(page)],
    "about" => ["About", about_settings]
  }
  active_label, content = tabs[tab] || tabs["system"]

  control(:view, route: route_path(page), bgcolor: BG, padding: 0,
    appbar: app_bar(bgcolor: BAR, color: TEXT,
      leading: icon_button(icon: "close", on_click: ->(_e) { studio_go(page, "/gallery") }),
      title: text("Settings", style: { color: TEXT, size: 20, weight: "w700" })),
    children: [
      column(expand: true, spacing: 0, children: [
        row(spacing: 0, children: tabs.keys.map do |key|
          label = tabs[key][0]
          container(padding: { left: 16, right: 16, top: 14, bottom: 14 },
            on_click: ->(_e) { studio_go(page, "/settings/#{key}") },
            content: text(label, style: { color: label == active_label ? BLUE : MUTED, size: 14 }))
        end),
        container(height: 1, bgcolor: BORDER),
        container(expand: true, padding: 20, content: content)
      ])
    ])
end

def system_settings(page)
  column(spacing: 18, children: [
    text("Theme", style: { color: TEXT, weight: "w700" }),
    control(:radio_group, value: studio_theme_mode, on_change: ->(event) { set_studio_theme(page, event.value) },
      content: column(spacing: 8, children: [
      control(:radio, value: "system", label: "System"),
      control(:radio, value: "light", label: "Light"),
      control(:radio, value: "dark", label: "Dark")
    ])),
    text("Editor", style: { color: TEXT, weight: "w700" }),
    row(spacing: 12, children: [text("Font size", style: { color: TEXT }), text_field(value: "13", width: 100)])
  ])
end

def about_settings
  column(spacing: 16, children: [
    text("App", style: { color: TEXT, weight: "w700" }),
    text("Ruflet Explorer version #{Ruflet::VERSION}", style: { color: TEXT }),
    text("Ruflet SDK version #{Ruflet::VERSION}", style: { color: TEXT }),
    text("Resources", style: { color: TEXT, weight: "w700" }),
    text("Docs, What's New, GitHub, Discord, Email", style: { color: MUTED })
  ])
end
