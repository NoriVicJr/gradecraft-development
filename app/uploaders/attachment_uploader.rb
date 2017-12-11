class AttachmentUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay

  # NOTE: course, assignment and assignment_file_type, and student should be
  # defined on the model in order to use them as subdirectories, otherwise
  # they will be ommited: submission_file: uploads/<course-name_id>/assignments/<assignment-name_id>/submission_files/<student_name>/timestamp_file_name.ext
  # assignment_file:  uploads/<course-name_id>/assignments/<assignment-name_id>/assignment_files/<timestamp_file-name.ext>
  # attachment: uploads/<course-name_id>/assignments/<assignment-name_id>/attachments/<timestamp_file-name.ext>
  # badge_file: uploads/<course-name_id>/badge_files/<timestamp_file-name.ext>
  # challenge_file: uploads/<course-name_id>/challenge_files/<timestamp_file-name.ext>

  def store_dir(overrides={})
    store_dir_pieces(overrides).join "/"
  end

  # Override the filename of the uploaded files:
  def filename
    if original_filename.present?
      if model && model.read_attribute(mounted_as).present?
        model.read_attribute(mounted_as)
      else
        "#{tokenized_name}.#{file.extension}"
      end
    end
  end

  # these are the components of the path where resources that have mounted this
  # uploader will be stored
  def store_dir_pieces(overrides={})
    [
      store_dir_prefix,
      "uploads",
      course(overrides.delete(:course_id)),
      assignment,
      file_klass,
      owner_name
    ].compact
  end

  def store_dir_prefix
    return unless Rails.env == "development"
    ENV["AWS_S3_DEVELOPER_TAG"]
  end

  # Course id on the path can be overridden if it is passed in
  # Used primarily during model copying
  def course(course_id=nil)
    # rubocop:disable AndOr
    "#{model.course.course_number}-#{course_id || model.course.id}" if model and model.class.method_defined? :course
  end

  def assignment
    "assignments/#{model.assignment.name.gsub(/\s/, "_").downcase[0..20]}-#{model.assignment.id}" if model.class.method_defined? :assignment
  end

  def file_klass
    return model.klass_name if model.class.method_defined? :klass_name
    klass_name = model.class.to_s.underscore.pluralize
  end

  def owner_name
    model.owner_name if model.class.method_defined? :owner_name
  end

  def tokenized_name
    model.instance_variable_get(secure_token_name) || model.instance_variable_set(secure_token_name, filename_from_basename)
  end

  def filename_from_basename
    "#{Time.now.to_i}_#{file.basename.gsub(/\W+/, "_").downcase[0..40]}"
  end

  def secure_token_name
    :"@#{mounted_as}_secure_token"
  end

  def extension_black_list
    %w(action apk app application bat bin cmd com command cpl csh dmg exe
    gadget hta inf ins inx ipa isu jar job jse lnk msc msh msh1 msh2 mshxml
    msh1xml msh2xml msi msp mst osx out paf pif prg psc1 psc2 ps1 ps1xml ps2
    ps2xml reg rgs run scf scr sct shb shs u3p vb vbe vbs vbscript workflow ws
    wsc wsf wsh)
  end
end
