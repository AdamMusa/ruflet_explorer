# frozen_string_literal: true

module RufletExplorer
  class App < Ruflet::App
    BRAND = "#6750A4"
    ERROR = "#BA1A1A"

    def initialize
      super
      @url_field = nil
      @status = nil
      @scanner = nil
      @scanner_message = nil
      @scan_handled = false
      @studio = nil
    end

    def view(page)
      @page = page
      @platform = page.platform.to_s
      configure_explorer_page

      configured_url = initial_url
      configured_url.empty? ? show_launcher : connect_to(configured_url)
    end

    private

    # `ruflet run --desktop` hands the server over in RUFLET_URL. On the web
    # there is no process environment, so the client is opened at /?url=<server>
    # and the target arrives in the page query instead.
    def initial_url
      from_env = ENV["RUFLET_URL"].to_s.strip
      return from_env unless from_env.empty?

      query = @page.respond_to?(:query) ? @page.query : nil
      return "" unless query.is_a?(Hash)

      value = query["url"] || query[:url]
      value = value.first if value.is_a?(Array)
      value.to_s.strip
    end

    def configure_explorer_page
      @page.title = "Ruflet Explorer"
      @page.theme_mode = "system"
      @page.theme = {
        use_material3: true,
        color_scheme_seed: BRAND
      }
      @page.bgcolor = nil
    end

    def show_launcher(error: nil)
      @scanner&.stop
      @scanner = nil
      @scan_handled = false
      configure_explorer_page
      @page.on_route_change = lambda do |_event|
        case @page.route.to_s.split("?").first
        when "/studio" then show_studio
        when "/scanner" then show_scanner
        when "/" then show_launcher
        end
      end
      @page.on_resize = nil
      @page.on_view_pop = nil
      @page.on(:platform_brightness_change) {}
      @page.views = []
      @page.route = "/"
      @page.padding = 0

      launcher_appbar = app_bar(
        title: text(value: "Ruflet Explorer", style: { weight: "w600" }),
        center_title: true
      )
      launcher_fab = fab(
        icon: "code",
        tooltip: "Open Ruflet Studio",
        on_click: ->(_event) { @page.go("/studio") }
      )

      @status = text(
        value: error || "Connect to a running Ruflet application.",
        color: error ? ERROR : nil,
        text_align: "center"
      )

      @url_field = text_field(
        "",
        label: "Server URL",
        hint_text: "http://192.168.1.20:8550",
        keyboard_type: "url",
        autocorrect: false,
        capitalization: "none",
        prefix_icon: icon("link"),
        on_change: lambda { |event|
          clear_url_error unless event.value.to_s.strip.empty?
        },
        on_submit: ->(event) { connect_to(event.value) }
      )

      connect_button = filled_button(
        "Connect",
        icon: "login",
        expand: true,
        height: 48,
        on_click: ->(_event) { connect_to(@url_field.props["value"]) }
      )

      scan_button = outlined_button(
        "Scan QR",
        icon: "qr_code_scanner",
        expand: true,
        height: 48,
        on_click: ->(_event) { @page.go("/scanner") }
      )

      content = container(
        padding: 28,
        content: column(
          spacing: 18,
          horizontal_alignment: "stretch",
          children: [
            icon("hub", size: 54, color: BRAND),
            text(
              value: "Connect to Ruflet",
              text_align: "center",
              style: { size: 26, weight: "w700" }
            ),
            text(
              value: "Enter the server address or scan the QR code shown by `ruflet run`.",
              text_align: "center",
              style: { size: 15 }
            ),
            @url_field,
            row(
              spacing: 12,
              children: [connect_button, scan_button]
            ),
            @status
          ]
        )
      )

      launcher_body = container(
        expand: true,
        alignment: "center",
        padding: 20,
        content: container(width: 560, content: content)
      )
      @launcher_view = control(
        :view,
        route: "/",
        padding: 0,
        appbar: launcher_appbar,
        floating_action_button: launcher_fab,
        children: [launcher_body]
      )
      @page.appbar = nil
      @page.floating_action_button = nil
      @page.controls = []
      @page.views = [@launcher_view]
    end

    def show_studio
      @scanner&.stop
      @scanner = nil
      @studio ||= Studio.new(@page, on_exit: -> { show_launcher })
      @studio.show
    end

    def show_scanner
      @scan_handled = false
      @page.route = "/scanner"
      @page.floating_action_button = nil
      @scanner_message = text(
        value: "Point the camera at the QR code shown by `ruflet run`.",
        color: "#FFFFFF",
        text_align: "center"
      )

      @scanner = QrScannerControl.new(
        expand: true,
        formats: %i[qr_code],
        camera_facing: :back,
        detection_speed: :no_duplicates,
        auto_zoom: false,
        zoom_scale: 0.0,
        tap_to_focus: true,
        on_detect: ->(event) { handle_scan(scan_payload(event)) },
        on_error: lambda { |event|
          message_text = event.data.is_a?(Hash) ? event.data["message"] : event.value
          @page.update(@scanner_message, value: "Camera error: #{message_text}", color: "#FFB4AB")
        }
      )

      scanner_appbar = app_bar(
        title: text(value: "Scan Ruflet QR"),
        leading: icon_button(
          "arrow_back",
          tooltip: "Back",
          on_click: ->(_event) { leave_scanner }
        ),
        actions: [
          icon_button(
            "flashlight_on",
            tooltip: "Toggle flashlight",
            on_click: ->(_event) { @scanner&.toggle_torch }
          ),
          icon_button(
            "cameraswitch",
            tooltip: "Switch camera",
            on_click: ->(_event) { @scanner&.switch_camera }
          )
        ]
      )

      scanner_body = stack(
        expand: true,
        children: [
          @scanner,
          container(
            left: 0,
            right: 0,
            bottom: 0,
            bgcolor: "#B3000000",
            padding: 16,
            content: @scanner_message
          )
        ]
      )
      scanner_view = control(
        :view,
        route: "/scanner",
        padding: 0,
        appbar: scanner_appbar,
        children: [scanner_body]
      )
      @page.appbar = nil
      @page.controls = []
      @page.views = [@launcher_view, scanner_view]
      @page.on_view_pop = lambda do |_event|
        @page.views.pop if @page.views.length > 1
        @page.go(@page.views.last&.props&.fetch("route", "/") || "/")
      end
    end

    def leave_scanner
      @scanner&.stop
      @page.go("/")
    end

    def handle_scan(payload)
      return if @scan_handled

      url = Url.normalize(payload, platform: @platform)
      unless url
        if @scanner_message
          @page.update(
            @scanner_message,
            value: "This QR code does not contain a valid Ruflet server URL.",
            color: "#FFB4AB"
          )
        end
        return
      end

      @scan_handled = true
      @scanner&.stop
      connect_to(url)
    end

    def scan_payload(event)
      data = event.respond_to?(:data) ? event.data : nil
      if data.is_a?(Hash)
        value = data["value"] || data[:value]
        return value unless value.to_s.empty?

        barcodes = data["barcodes"] || data[:barcodes]
        first = Array(barcodes).first
        if first.is_a?(Hash)
          return first["raw_value"] || first[:raw_value] ||
            first["display_value"] || first[:display_value]
        end
      end

      return event.value if event.respond_to?(:value)
      return event.raw_data if event.respond_to?(:raw_data) && event.raw_data.is_a?(String)

      nil
    end

    def connect_to(payload)
      return show_url_error("Server URL is required.") if payload.to_s.strip.empty?

      url = Url.normalize(payload, platform: @platform)
      return show_url_error("Enter a valid Ruflet server URL.") unless url

      @scanner&.stop
      @scanner = nil
      @page.views = []
      @page.appbar = nil
      @page.floating_action_button = nil
      @page.padding = 0
      @page.controls = [
        ruflet_app(
          url: url,
          expand: true,
          show_app_startup_screen: true,
          app_startup_screen_message: "Connecting to Ruflet…",
          app_error_message: "Unable to load this Ruflet application: {message}",
          reconnect_interval_ms: 500,
          reconnect_timeout_ms: 10_000,
          on_error: lambda { |event|
            message = event.data.is_a?(Hash) ? event.data["message"] : event.value
            show_launcher(error: "Connection failed: #{message}")
          }
        )
      ]
    end

    def show_url_error(message)
      return show_launcher(error: message) unless @url_field && @page.views.include?(@launcher_view)

      @page.update(@url_field, error: message)
    end

    def clear_url_error
      return unless @url_field&.props&.key?("error")

      @page.update(@url_field, error: nil)
    end
  end
end
