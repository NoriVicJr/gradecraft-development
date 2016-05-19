require "light-service"
require_relative "creates_earned_badge/creates_earned_badge"
require_relative "creates_earned_badge/notifies_of_earned_badge"
require_relative "creates_earned_badge/recalculates_student_score"

module Services
  class CreatesEarnedBadge
    extend LightService::Organizer

    def self.award(params)
      with(params: params).reduce(
        Actions::CreatesEarnedBadge,
        Actions::RecalculatesStudentScore,
        Actions::NotifiesOfEarnedBadge
      )
    end
  end
end
