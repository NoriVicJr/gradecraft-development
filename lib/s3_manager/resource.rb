module S3Manager
  module Resource
    def s3_manager
      @s3_manager ||= S3Manager::Manager.new
    end

    def upload_file_to_s3(file_path)
      s3_manager.put_encrypted_object(s3_object_key, file_path)
    end

    def fetch_object_from_s3
      s3_manager.get_encrypted_object(s3_object_key)
    end

    def stream_s3_object_body
      s3_object = fetch_object_from_s3
      return unless s3_object and s3_object.body
      s3_object.body.read
    end

    def write_s3_object_to_file(target_file_path)
      s3_manager.write_encrypted_object_to_file(s3_object_key, target_file_path)
    end

    def delete_object_from_s3
      s3_manager.delete_object(s3_object_key)
    end

    def update_export_completed_time
      update_attributes last_export_completed_at: Time.now
    end

    def s3_object_exists?
      s3_object_summary.exists?
    end

    def s3_object_summary
      @s3_object_summary ||= S3Manager::Manager::ObjectSummary
        .new(s3_object_key, s3_manager)
    end

    def presigned_s3_url
      return unless s3_object_key
      s3_manager.bucket.object(s3_object_key)
        .presigned_url(:get, expires_in: 604800).to_s
    end

    def build_s3_object_key(object_filename)
      key_pieces = [ s3_object_key_prefix, object_filename ].flatten
      key_pieces.unshift ENV["AWS_S3_DEVELOPER_TAG"] if Rails.env.development?
      key_pieces.join "/"
    end
  end
end
