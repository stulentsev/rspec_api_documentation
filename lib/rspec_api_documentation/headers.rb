module RspecApiDocumentation
  module Headers
    private

    def env_to_headers(env)
      headers = {}
      env.each do |key, value|
        # HTTP_ACCEPT_CHARSET => Accept-Charset
        if key =~ /^(HTTP_|CONTENT_TYPE)/
          header = key.gsub(/^HTTP_/, '').titleize.split.join("-")
          headers[header] = value
        end
      end
      headers
    end

    def headers_to_env(headers)
      headers # above conversion doesn't play well when target host is a rails app
              # instead of HTTP_FOO, one gets HTTP_HTTP_FOO
    end

    def format_headers(headers)
      headers.map do |key, value|
        "#{key}: #{value}"
      end.join("\n")
    end
  end
end
