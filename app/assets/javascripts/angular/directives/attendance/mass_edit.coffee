@gradecraft.directive 'attendanceMassEdit', ['AttendanceService', (AttendanceService) ->
  AttendanceMassEditCtrl = [() ->
    vm = this
    vm.loading = true

    AttendanceService.getAttendanceAssignments().then(() ->
      vm.loading = false
    )
  ]

  {
    bindToController: true
    controller: AttendanceMassEditCtrl
    controllerAs: 'massEditCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/mass_edit.html'
  }
]
