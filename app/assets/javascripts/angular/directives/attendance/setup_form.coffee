@gradecraft.directive 'attendanceSetupForm', ['AttendanceService', (AttendanceService) ->
  AttendanceSetupFormCtrl = [() ->
    vm = this

    vm.attributes = AttendanceService.attendanceAttributes

    vm.postAttendanceArticle = (selectedDays) ->
      vm.attributes.selectedDays = selectedDays if selectedDays?
      AttendanceService.postAttendanceArticle()
  ]

  {
    scope:
      cancelRoute: '@'
    bindToController: true
    controller: AttendanceSetupFormCtrl
    controllerAs: 'setupCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/setup_form.html'
  }
]
