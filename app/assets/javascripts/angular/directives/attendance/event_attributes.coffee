@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  {
    scope:
      disableEdit: '&'
      hideBackButton: '@'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    require: '^form'
    templateUrl: 'attendance/_event_attributes.html'
    link: (scope, el, attr, ngForm) ->
      scope.events = AttendanceService.events
      scope.lastUpdated = AttendanceService.lastUpdated
      scope.saveChanges = AttendanceService.saveChanges
      scope.form = ngForm

      scope.hasPersistedEvents = () ->
        _.any(scope.events, (a) -> a.id?)
  }
]
