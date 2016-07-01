require "canvas"

module LMSImporter
  class CanvasCourseImporter
    def initialize(access_token)
      @client = Canvas::API.new(access_token)
    end

    def courses
      @courses || begin
        @courses= []
        client.get_data("/courses", enrollment_type: "teacher") do |courses|
          @courses += courses
        end
      end
      @courses
    end

    private

    attr_reader :client
  end
end
