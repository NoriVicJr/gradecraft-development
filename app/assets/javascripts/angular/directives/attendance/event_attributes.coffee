@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  {
    scope:
      disableEdit: '&'
      hideBackButton: '@'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/_event_attributes.html'
    link: (scope, el, attr) ->
      scope.events = AttendanceService.events
      scope.lastUpdated = AttendanceService.lastUpdated

      scope.hasPersistedEvents = () ->
        _.any(scope.events, (a) -> a.id?)
  }
]
