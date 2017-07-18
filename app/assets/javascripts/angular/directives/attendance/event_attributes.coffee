@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  {
    scope:
      disableEdit: '&'
      termForSave: '@'
      displayBackButton: '@'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/_event_attributes.html'
    require: '^form'  # requires parent form
    link: (scope, el, attr, form) ->
      scope.saved = AttendanceService.saved
      scope.assignments = AttendanceService.assignments
      scope.form = form
  }
]
