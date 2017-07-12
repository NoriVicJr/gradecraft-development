@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  {
    scope:
      disableEdit: '&'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/event_attributes.html'
    require: '^form'  # requires parent form
    link: (scope, el, attr, form) ->
      scope.saved = AttendanceService.saved
      scope.assignments = AttendanceService.assignments
      scope.attendanceAttributes = AttendanceService.attendanceAttributes
      scope.form = form
  }
]
