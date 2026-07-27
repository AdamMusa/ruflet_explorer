# frozen_string_literal: true

module RufletExplorer
  class QrScannerControl < Ruflet::Control
    def initialize(id: nil, **props)
      normalized = props.dup
      normalized[:formats] = Array(normalized[:formats]).map(&:to_s) if normalized.key?(:formats)
      super(type: "qrcode_scanner", id: id, **normalized)
    end

    def start(timeout: 10, on_result: nil)
      invoke("start", timeout: timeout, on_result: on_result)
    end

    def stop(timeout: 10, on_result: nil)
      invoke("stop", timeout: timeout, on_result: on_result)
    end

    def switch_camera(timeout: 10, on_result: nil)
      invoke("switch_camera", timeout: timeout, on_result: on_result)
    end

    def toggle_torch(timeout: 10, on_result: nil)
      invoke("toggle_torch", timeout: timeout, on_result: on_result)
    end

    private

    def invoke(name, timeout:, on_result:)
      runtime_page&.invoke(self, name, timeout: timeout, on_result: on_result)
    end
  end
end
