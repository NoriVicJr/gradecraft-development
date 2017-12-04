require "light-service"
require_relative "creates_earned_badge/notifies_of_earned_badge"

module Services
  class NotifiesEarnedBadge
    extend LightService::Organizer

    def self.notify(earned_badge)
      with(earned_badge: earned_badge, notify: true).reduce Actions::NotifiesOfEarnedBadge
    end
  end
end
