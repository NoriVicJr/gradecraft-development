@gradecraft.directive 'gradeEarnedBadgesSelect', ['GradeService', 'BadgeService', (GradeService, BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)

    # Has the student currently earned this badge on this grade?
    vm.badgeIsEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId, badge.id, GradeService.grades[0].id)

    # Can the badge be awarded or unawarded for this grade?
    vm.badgeIsActionable = (badge)->
      badge.available_for_student || vm.badgeIsEarnedForGrade(badge)

    # Can the badge be awarded for this grade?
    vm.badgeIsAwardable = (badge)->
      badge.available_for_student && !vm.badgeIsEarnedForGrade(badge)

    # For accessibility, each checkbox must have a label with a unique id
    vm.inputId = (badge)->
      badge.name.toLowerCase().replace(/[\W]/g,"-") + badge.id

    # ACTION: toggle the badge award on this grade.
    #  - award if unawarded
    #  - remove if currently awarded
    vm.awardBadge = (badge)->
      return if !vm.badgeIsActionable(badge)
      if earnedBadge = vm.badgeIsEarnedForGrade(badge)
        BadgeService.deleteEarnedBadge(earnedBadge)
        badge.available_for_student = true
      else
        BadgeService.createEarnedBadge(badge.id, vm.studentId, GradeService.grades[0].id, false).then(
          (response) ->
            badge.pending_notify = true
          , (response) ->
            console.error("Failed to create earned badge")
        )
  ]

  {
    bindToController: true,
    controller: AwardedBadgesCtrl,
    controllerAs: 'vm',
    scope: {
      studentId: '@'
    },
    templateUrl: 'grades/earned_badges_select.html'
  }
]

