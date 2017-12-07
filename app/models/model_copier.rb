class ModelCopier
  attr_reader :original, :copied, :lookup_store

  def initialize(model, lookup_store=nil)
    @original = model
    @lookup_store = lookup_store || ModelCopierLookups.new
  end

  def copy(options={})
    @copied = original.dup
    attributes = options.delete(:attributes) {{}}
    copied.copy_attributes attributes
    handle_options options.delete(:options) {{}}
    # call save so we have an id on the copy to store
    copied.save
    lookup_store.store(original, copied)
    copy_associations options.delete(:associations) {[]}, attributes
    copied
  end

  private

  def copy_associations(associations, attributes)
    ModelAssociationCopier.new(original, copied, lookup_store).copy([associations].flatten, attributes)
  end

  def handle_options(options)
    prepend_attributes options.delete(:prepend) {{}}
    run_overrides options.delete(:overrides) {{}}
    run_lookups options.delete(:lookups) {[]}
  end

  def prepend_attributes(attributes)
    attributes.each_pair do |attribute, text|
      copied.send(attribute).prepend text
    end
  end

  def run_overrides(overrides)
    overrides.each { |override| override.call copied }
  end

  # lookups: [:courses, :badges,...]
  def run_lookups(lookups)
    lookup_store.assign_values_to_attributes(lookups, original).each do |k,v|
      copied[k] = v
    end
  end

  class ModelAssociationCopier
    attr_reader :original, :copied, :lookup_store

    def initialize(original, copied, lookup_store)
      @original = original
      @copied = copied
      @lookup_store = lookup_store
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

    # This will create duplicates of all associated models from the original,
    # and add them to copied. In the process, the belongs_to id on the association
    # will be correctly updated to the copy id.
    # example:
    # If copied and original are Courses, and association == :badges
    # this will create an array of duplicate badges from original and send:
    # copied.badges << [copied_badge_1, copied_badge_2,...]
    # and all copied_badges course_id will be updated to copied.id
    def add_association(association, attributes)
      copied.send(association).send "<<", original.send(association).map { |child| child.copy(attributes, lookup_store) }
    end
  end

  class AssociationAttributeParser
    attr_reader :association
    attr_reader :attributes

    def initialize(association)
      @association = association
    end

    # target is the copied model
    def parse(target)
      split_attributes_from_association
      @association = association.keys.first
      assign_values_to_attributes target
      self
    end

    # association is specified as { association: { attributes }} and this
    # splits out the attributes
    # for example:
    # assignment_types: { course_id: :id } returns: { course_id: :id }
    def split_attributes_from_association
      @attributes = association.values.inject({}) { |hash, element| hash.merge!(element) }
    end

    # target is the copied model, for each attribute hash, the value is
    # called on the copy and replaces the symbol on in the attributes hash
    # example: if target is a course with id of 555
    # before: @attributes[:course_id] = :id
    # after: @attributes[:course_id] = 555
    def assign_values_to_attributes(target)
      attributes.each_pair do |attribute, value|
        attributes[attribute] = target.send(value) if value.is_a? Symbol
      end
    end
  end
end

class ModelCopierLookups

  # example:
  # {:courses=>{1=>2}, :badges=>{3=>4}}
  attr_reader :lookup_hash

  def initialize
    @lookup_hash = {}
  end

  # stores the associated id of the copy by class
  # example:
  # original: course (id: 1)
  # coppied: course (id: 2)
  # store adds :courses=>{1=>2} to the lookup hash
  def store(original, copied)
    type = original.class.name.underscore.pluralize.to_sym
    lookup_hash[type] ||= {}
    lookup_hash[type][original.id] = copied.id
  end

  def lookup_has_key?(type, id)
    return false unless lookup_hash[type].present?
    return false unless lookup_hash[type][id].present?
    return true
  end

  # returns the id of the copy associated with the original id
  # example: lookup(:badges, 3) returns 4
  def lookup(type, id)
    lookup_hash[type][id] if lookup_has_key?(type, id)
  end

  # lookups = [:courses, :badges]
  # returns: {course_id: 1, badge_id: 4}
  def assign_values_to_attributes(lookups, original)
    lookups.inject({}) do |h, class_type|

      # :courses => :course_id
      id_key = "#{class_type.to_s.singularize}_id".to_sym

      if original.respond_to?(id_key) && lookup_has_key?(class_type, original.send(id_key))
        h[id_key] = lookup(class_type, original.send(id_key))
      end
      h
    end
  end
end
