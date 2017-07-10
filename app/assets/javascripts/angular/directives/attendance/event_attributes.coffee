@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  AttendanceEventAttributesCtrl = [() ->
    vm = this
  ]

  {
    bindToController: true
    controller: AttendanceEventAttributesCtrl
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/event_attributes.html'
    require: '^form'  # requires parent form
    link: (scope, el, attr, form) ->
      scope.assignments = AttendanceService.assignments
      scope.attendanceAttributes = AttendanceService.attendanceAttributes
      scope.form = form
  }
]
