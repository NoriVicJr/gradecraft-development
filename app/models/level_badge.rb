class LevelBadge < ActiveRecord::Base
  include Copyable

  belongs_to :level
  belongs_to :badge

  validates :level_id, uniqueness: { scope: :badge_id }

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: { lookups: [:badges, :levels] }
    )
  end
end
