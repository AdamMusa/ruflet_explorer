# frozen_string_literal: true

module RufletExplorer
  module Url
    SUPPORTED_SCHEMES = %w[http https ws wss].freeze
    LOCAL_HOSTS = %w[0.0.0.0 :: 127.0.0.1 localhost ::1].freeze
    URL_PATTERN = %r{(?:https?|wss?)://[^\s]+}i
    URL_PARTS_PATTERN = %r{\A(https?|wss?)://([^/\s?#]+)([^\s]*)\z}i

    module_function

    def normalize(payload, platform: nil)
      raw = payload.to_s.strip
      return nil if raw.empty?

      candidate = raw[URL_PATTERN] || raw
      candidate = add_scheme(candidate)
      match = URL_PARTS_PATTERN.match(candidate)
      return nil unless match

      source_scheme = match[1].downcase
      authority = match[2]
      remainder = match[3].to_s
      host, port = split_authority(authority)
      return nil if host.empty?

      host = "10.0.2.2" if platform.to_s.downcase == "android" && local_host?(host)
      scheme = source_scheme == "wss" ? "https" : (source_scheme == "ws" ? "http" : source_scheme)
      path_and_query = normalized_remainder(remainder, websocket: %w[ws wss].include?(source_scheme))
      "#{scheme}://#{format_authority(host, port)}#{path_and_query}"
    end

    def add_scheme(value)
      return value if value =~ %r{\A[a-z][a-z0-9+.-]*://}i

      authority = value.split("/", 2).first.to_s
      host, = split_authority(authority)
      is_ip = host =~ /\A\d{1,3}(?:\.\d{1,3}){3}\z/
      scheme = local_host?(host) || is_ip ? "http" : "https"
      "#{scheme}://#{value}"
    end

    def split_authority(authority)
      if authority.start_with?("[")
        closing = authority.index("]")
        return ["", nil] unless closing

        host = authority[1...closing]
        port = authority[(closing + 1)..]
        port = port.delete_prefix(":") if port&.start_with?(":")
        [host, port]
      else
        host, separator, port = authority.rpartition(":")
        return [authority, nil] if separator.empty? || port !~ /\A\d+\z/

        [host, port]
      end
    end

    def format_authority(host, port)
      formatted_host = host.include?(":") ? "[#{host}]" : host
      port.to_s.empty? ? formatted_host : "#{formatted_host}:#{port}"
    end

    def normalized_remainder(value, websocket:)
      remainder = value.split("#", 2).first.to_s
      remainder = remainder.split("?", 2).first.to_s if websocket
      remainder == "/ws" ? "" : remainder
    end

    def local_host?(host)
      LOCAL_HOSTS.include?(host.to_s.downcase.delete_prefix("[").delete_suffix("]"))
    end
  end
end
