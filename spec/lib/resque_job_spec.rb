require_relative '../../lib/is_configurable'
require_relative '../toolkits/lib/is_configurable/shared_examples'

describe ResqueJob, type: :vendor_library do
  include Toolkits::Lib::IsConfigurableToolkit::SharedExamples

  # this is a mock configuration intended to match the configurable attributes
  # for the target class in which IsConfigurable is included
  demo_config = {
    backoff_strategy: [5, 6, 7]
  }

  it_behaves_like "it is configurable", ResqueJob, demo_config
end
