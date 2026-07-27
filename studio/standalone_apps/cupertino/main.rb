# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "Cupertino controls"
  page.theme_mode = "system"
  page.bgcolor = "#ffffff"
  status = text(value: "", style: { size: 12, color: "#6b7280" })
  dark = page.platform_brightness.to_s == "dark"
  field_bg = dark ? "#1E293B" : "#FFFFFF"
  field_text = dark ? "#F1F5F9" : "#172033"
  field_muted = dark ? "#94A3B8" : "#64748B"
  field_border = dark ? "#475569" : "#CBD5E1"
  radio_group_control = radio_group(
    value: "r1",
    on_change: lambda { |event|
      page.update(status, value: "Radio: #{event.value}")
    },
    content: row(
      spacing: 8,
      children: [
        cupertino_radio(label: "Radio 1", value: "r1"),
        cupertino_radio(label: "Radio 2", value: "r2")
      ]
    )
  )
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: list_view(
        expand: true,
        spacing: 12,
        children: [
          status,
          cupertino_text_field(
            height: 48,
            placeholder_text: "Type something",
            bgcolor: field_bg,
            color: field_text,
            placeholder_style: { color: field_muted, size: 15 },
            border_color: field_border,
            focused_border_color: "#38BDF8",
            border_width: 1,
            focused_border_width: 2,
            border_radius: 12,
            content_padding: { left: 14, right: 14, top: 12, bottom: 12 },
            clear_button_visibility_mode: "editing"
          ),
          cupertino_checkbox(
            label: "Checkbox",
            value: false,
            on_change: lambda { |event|
              page.update(status, value: "Checkbox: #{event.value}")
            }
          ),
          cupertino_switch(
            label: "Switch",
            value: false,
            on_change: lambda { |event|
              page.update(status, value: "Switch: #{event.value}")
            }
          ),
          cupertino_slider(
            min: 0,
            max: 100,
            divisions: 10,
            value: 50,
            on_change_end: lambda { |event|
              page.update(status, value: "Slider: #{event.value}")
            }
          ),
          radio_group_control
        ]
      )
    )
  )
end
