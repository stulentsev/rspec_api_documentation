require 'active_support/core_ext/object/to_query'
require 'base64'

module RspecApiDocumentation
  class Curl < Struct.new(:method, :path, :data, :headers)
    attr_accessor :host

    def output(config_host, config_headers_to_filer = nil)
      self.host = config_host
      @config_headers_to_filer = Array(config_headers_to_filer)
      send(method.downcase)
    end

    def post
      "curl \"#{url}\" #{post_data} -X POST #{curl_options(method)} #{headers}"
    end

    def get
      "curl \"#{url}#{get_data}\" -X GET #{curl_options(method)} #{headers}"
    end

    def head
      "curl \"#{url}#{get_data}\" -X HEAD #{curl_options(method)} #{headers}"
    end

    def put
      "curl \"#{url}\" #{post_data} -X PUT #{curl_options(method)} #{headers}"
    end

    def delete
      "curl \"#{url}\" #{post_data} -X DELETE #{curl_options(method)} #{headers}"
    end

    def patch
      "curl \"#{url}\" #{post_data} -X PATCH #{curl_options(method)} #{headers}"
    end

    def url
      "#{host}#{path}"
    end

    def headers
      filter_headers(super).map do |k, v|
        if k =~ /authorization/i && v =~ /^Basic/
          "\\\n\t-u #{format_auth_header(v)}"
        else
          "\\\n\t-H \"#{format_full_header(k, v)}\""
        end
      end.join(" ")
    end

    def get_data
      "?#{data}" unless data.blank?
    end

    def post_data
      escaped_data = data.to_s.gsub("'", "\\u0027")
      "-d '#{escaped_data}'"
    end

    def curl_options(method)
      if method.downcase == 'get'
        '--globoff' # don't complain about brackets in a query string
      else
        ''
      end
    end

    private

    def format_auth_header(value)
      ::Base64.decode64(value.split(' ', 2).last || '')
    end

    def format_header(header)
      header.gsub(/^HTTP_/, '').titleize.split.join("-")
    end

    def format_full_header(header, value)
      formatted_value = value ? value.gsub(/"/, "\\\"") : ''
      "#{format_header(header)}: #{formatted_value}"
    end

    def filter_headers(headers)
      if !@config_headers_to_filer.empty?
        headers.reject do |header|
          @config_headers_to_filer.include?(format_header(header))
        end
      else
        headers
      end
    end
  end
end
