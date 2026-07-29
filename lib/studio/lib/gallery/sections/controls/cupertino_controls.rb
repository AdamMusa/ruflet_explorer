# frozen_string_literal: true

# === gallery/sections_controls/cupertino_controls.rb ===
module Gallery
  module SectionsControls
    def build_cupertino_controls(page, status)
      radio_group_control = radio_group(
        value: "r1",
        on_change: lambda { |event|
          page.update(status, value: "Radio: #{event.value}")
        },
        content: row(
          spacing: 8,
          children: [
            control(:cupertino_radio, label: "Radio 1", value: "r1"),
            control(:cupertino_radio, label: "Radio 2", value: "r2")
          ]
        )
      )

      list_view(
        expand: true,
        spacing: 12,
        children: [
          status,
          control(
            :cupertino_text_field,
            height: 48,
            placeholder_text: "Type something",
            bgcolor: color_surface(page),
            color: color_text(page),
            placeholder_style: { color: color_subtle(page), size: 15 },
            border_color: color_divider(page),
            focused_border_color: color_accent(page),
            border_width: 1,
            focused_border_width: 2,
            border_radius: 12,
            content_padding: { left: 14, right: 14, top: 12, bottom: 12 },
            clear_button_visibility_mode: "editing"
          ),
          control(
            :cupertino_checkbox,
            label: "Checkbox",
            value: false,
            on_change: lambda { |event|
              page.update(status, value: "Checkbox: #{event.value}")
            }
          ),
          control(
            :cupertino_switch,
            label: "Switch",
            value: false,
            on_change: lambda { |event|
              page.update(status, value: "Switch: #{event.value}")
            }
          ),
          control(
            :cupertino_slider,
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
    end
  end
end
