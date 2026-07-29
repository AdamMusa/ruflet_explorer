# frozen_string_literal: true

require "ruflet"

Ruflet.run do |page|
  page.padding = 0
  page.title = "To-do"
  page.theme_mode = "system"

  todos = [
    { text: "Buy milk", done: false },
    { text: "Write docs", done: true }
  ]
  draft = ""
  list = column(spacing: 4)

  # `publish` is false for the initial fill, which runs before page.add: the
  # list is not mounted yet, so patching here describes a page the client
  # cannot resolve.
  refresh = lambda do |publish = true|
    list.children.replace(
      todos.each_with_index.map do |item, i|
        row(
          alignment: "spaceBetween",
          children: [
            checkbox(
              label: item[:text],
              value: item[:done],
              on_change: ->(e) { item[:done] = [true, "true", "1", 1].include?(e.data) }
            ),
            icon_button(
              icon: "delete",
              on_click: ->(_e) { todos.delete_at(i); refresh.call }
            )
          ]
        )
      end
    )
    page.update if publish
  end

  field = text_field(
    hint_text: "What needs to be done?",
    expand: true,
    on_change: ->(e) { draft = e.data.to_s }
  )

  add = lambda do
    return if draft.strip.empty?

    todos << { text: draft.strip, done: false }
    draft = ""
    page.update(field, value: "")
    refresh.call
  end

  refresh.call(false)
  page.add(
    container(
      expand: true,
      alignment: "center",
      padding: 24,
      content: column(
        width: 380,
        spacing: 12,
        children: [
          text(value: "Todos", style: { size: 24, weight: "w700" }),
          row(spacing: 8, children: [
            field,
            filled_button(content: text(value: "Add"), on_click: ->(_e) { add.call })
          ]),
          list,
          outlined_button(
            content: text(value: "Clear completed"),
            on_click: ->(_e) { todos.reject! { |t| t[:done] }; refresh.call }
          )
        ]
      )
    )
  )
end
