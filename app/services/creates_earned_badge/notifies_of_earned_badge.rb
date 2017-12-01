module Services
  module Actions
    class NotifiesOfEarnedBadge
      extend LightService::Action

      expects :earned_badge, :notify

      executed do |context|
        earned_badge = context.earned_badge
        notify = context.notify

        if notify && earned_badge.student_visible?
          EarnedBadgeAnnouncement.create earned_badge
          if earned_badge.student.email_badge_awards?(earned_badge.course)
            NotificationMailer.earned_badge_awarded(earned_badge).deliver_now
          end
        end
      end
    end
  end
end
