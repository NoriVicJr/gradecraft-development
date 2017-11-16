module Copyable
  extend ActiveSupport::Concern

  def copy(attributes={}, lookup=nil)
    lookup ||= ModelCopierLookups.new
    copy = self.dup
    copy.copy_attributes(attributes)
    copy.save
    lookup.store(self, copy)
    copy
  end

  def copy_attributes(attributes)
    attributes.each do |name, value|
      method = "#{name}="
      if self.respond_to? method
        self.send method, value
      end
    end
  end
end
