module S3Manager
  class ObjectStream
    include S3Manager::Basics

    attr_accessor :object_key

    def initialize(object_key:)
      @object_key = object_key
    end

    def object
      @object ||= get_object object_key
    end

    def exists?
      !!(object && object.body)
    end

    def stream!
      return false unless exists?
      object.body.read
    end
  end
end
