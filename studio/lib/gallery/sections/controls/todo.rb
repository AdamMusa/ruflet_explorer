# frozen_string_literal: true

# === gallery/sections_controls/todo.rb ===
module Gallery
  module SectionsControls
    def build_todo(page, _status)
      todos = [
        { text: "Buy milk", done: false },
        { text: "Write docs", done: true }
      ]

      input_text = ""
      input = text_field(
        hint_text: "What needs to be done?",
        on_change: ->(e) { input_text = e.data.to_s }
      )
      list = column(spacing: 6, children: [])

      # `publish` is false for the initial fill: the section is still being
      # built, so `list` is not mounted on the page yet and pushing a patch
      # here describes a tree the client cannot resolve.
      render_list = lambda do |publish = true|
        new_controls = todos.each_with_index.map do |item, idx|
          checkbox_control = checkbox(
            label: item[:text],
            value: item[:done],
            on_change: ->(e) {
              val = read_number(e.data, "value")
              if val.nil?
                payload = e.data.to_s
                val = payload == "true" || payload == "1"
              end
              todos[idx][:done] = val == 1 || val == true
              render_list.call
            }
          )

          row(
            alignment: "spaceBetween",
            children: [
              checkbox_control,
              icon_button(
                icon: "delete",
                tooltip: "Delete",
                on_click: ->(_e) {
                  todos.delete_at(idx)
                  render_list.call
                }
              )
            ]
          )
        end

        list.children.replace(new_controls)
        page.update if publish
      end

      add_todo = lambda do
        text = input_text.to_s.strip
        return if text.empty?

        todos << { text: text, done: false }
        page.update(input, value: "")
        render_list.call
      end

      render_list.call(false)

      column(
        spacing: 8,
        children: [
          text(value: "Todos", style: { size: 20, weight: "w600" }),
          input,
          button(content: text(value: "Add"), on_click: ->(_e) { add_todo.call }),
          list,
          control(
            :outlined_button,
            content: text(value: "Clear completed"),
            on_click: ->(_e) {
              todos.reject! { |item| item[:done] }
              render_list.call
            }
          )
        ]
      )
    end
  end
end
