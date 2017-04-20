require_relative "../../importers/user_importers"

module Services
  module Actions
    class ImportsLMSUsers
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :course, :provider, :users
      promises :users_import_result

      executed do |context|
        course = context.course
        users = context.users
        provider = context.provider

        klass = constantize("#{camelize(provider)}UserImporter")
        context.users_import_result = klass.new(users).import course
      end
    end
  end
end
