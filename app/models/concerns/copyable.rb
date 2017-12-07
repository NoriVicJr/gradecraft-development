module Copyable
  extend ActiveSupport::Concern

  def copy(attributes={}, lookup_store=nil)
    lookup_store ||= ModelCopierLookups.new
    copy = self.dup
    copy.copy_attributes(attributes)
    # call save so we have an id on the copy to store
    copy.save
    lookup_store.store(self, copy)
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
