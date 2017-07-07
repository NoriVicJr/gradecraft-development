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
    link: (scope, el, attr) ->
      scope.selectedDates = AttendanceService.selectedDates
      scope.attendanceAttributes = AttendanceService.attendanceAttributes
  }
]
