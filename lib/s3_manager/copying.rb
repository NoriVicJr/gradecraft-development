module S3Manager
  module Copying
    
    # Use in conjunction with Carrierwave attached files
    # https://github.com/carrierwaveuploader/carrierwave#uploading-files-from-a-remote-location
    #
    # Takes a copied model and its original and verifies that the file exists
    # prior to copying
    def remote_upload(copy, original, mounted_as, url)
      begin
        copy.send("remote_#{mounted_as}_url=", url) if exists_remotely?(original, mounted_as)
      rescue CarrierWave::UploadError => e
        yield e if block_given?
      end
    end

    # Performs an HTTP call to validate that the linked file actually exists
    def exists_remotely?(model, mounted_as)
      !model.send(mounted_as).file.nil? && model.send(mounted_as).file.exists?
    end
  end
end
