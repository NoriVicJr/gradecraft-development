class ModelCopier
  attr_reader :original, :copied, :lookups

  def initialize(model, lookups=nil)
    @original = model
    @lookups = lookups || ModelCopierLookups.new
  end

  def copy(options={})
    @copied = original.dup
    attributes = options.delete(:attributes) {{}}
    copied.copy_attributes attributes
    handle_options options.delete(:options) {{}}
    copied.save! unless original.new_record?
    lookups.set(original, copied)
    copy_associations options.delete(:associations) {[]}, attributes
    copied
  end

  private

  def copy_associations(associations, attributes)
    ModelAssociationCopier.new(original, copied, lookups).copy([associations].flatten, attributes)
  end

  def handle_options(options)
    prepend_attributes options.delete(:prepend) {{}}
    run_overrides options.delete(:overrides) {{}}
  end

  def prepend_attributes(attributes)
    attributes.each_pair do |attribute, text|
      copied.send(attribute).prepend text
    end
  end

  def run_overrides(overrides)
    overrides.each { |override| override.call copied }
  end

  class ModelAssociationCopier
    attr_reader :original, :copied, :lookups

    def initialize(original, copied, lookups)
      @original = original
      @copied = copied
      @lookups = lookups
    end

    def copy(associations, attributes)
      associations.each { |association| copy_association(association, attributes) }
    end

    def copy_association(association, attributes)
      if association.is_a? Hash
        add_association_with_attributes association, attributes
      else
        add_association association, attributes
      end
    end

    def add_association_with_attributes(association, attributes)
      parsed = AssociationAttributeParser.new(association).parse(copied)
      add_association parsed.association, attributes.merge(parsed.attributes)
    end

    def add_association(association, attributes)
      copied.send(association).send "<<", original.send(association).map { |child| child.copy(attributes, lookups) }
    end
  end

  class AssociationAttributeParser
    attr_reader :association
    attr_reader :attributes

    def initialize(association)
      @association = association
    end

    def parse(target)
      split_attributes_from_association
      @association = association.keys.first
      assign_values_to_attributes target
      self
    end

    def split_attributes_from_association
      # association is specified as { association: { attributes }} and this
      # splits out the attributes
      @attributes = association.values.inject({}) { |hash, element| hash.merge!(element) }
    end

    def assign_values_to_attributes(target)
      attributes.each_pair do |attribute, value|
        attributes[attribute] = target.send(value) if value.is_a? Symbol
      end
    end
  end
end

class ModelCopierLookups
  attr_reader :lookup_hash

  def initialize
    @lookup_hash = {}
  end

  def set(original, copied)
    type = original.class.name.underscore.to_sym
    lookup_hash[type] ||= {}
    lookup_hash[type][original.id] = copied.id
  end

  # use:
  # ModelCopierLookups.lookup(:badges, 1)
  # returns the id of the copy associated with the original id
  def lookup(type, id)
    return false unless type.present? && id.present?
    return false unless lookup_hash[type].present?
    lookup_hash[type][id]
  end
end
