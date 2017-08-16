@gradecraft.directive 'badgeEditBasics', ['BadgeService', (BadgeService) ->

  return {
    scope: {
      badge: "="
    }
    templateUrl: 'badges/edit_basics.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = BadgeService.termFor

      scope.updateBadge = ()->
        BadgeService.queueUpdateBadge(@badge.id)
  }
]
