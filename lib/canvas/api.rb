require "httparty"

module Canvas
  class API
    include HTTParty
    base_uri "https://canvas.instructure.com/api/v1"
    format :json

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def get_data(path="/", params={})
      params.merge! access_token: access_token
      next_url = "#{self.class.base_uri}#{path}"
      while next_url
        response = self.class.get(next_url, query: params)
        raise ResponseError.new(response) unless response.success?
        yield response.parsed_response if block_given?
        next_url = get_next_url response
      end
    end

    private

    def get_next_url(resp)
      if resp.headers["Link"]
        resp.headers["Link"].split(",").each do |link|
          matches = link.match(/^<(.*)>; rel="(.*)"/)
          unless matches.nil?
            url, rel = matches.captures
            return url if rel == "next"
          end
        end
      end
      nil
    end
  end
end
