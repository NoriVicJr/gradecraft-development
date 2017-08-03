@gradecraft.directive 'attendanceSetupForm', ['AttendanceService', (AttendanceService) ->
  AttendanceSetupFormCtrl = [() ->
    vm = this
    vm.editingEvents = false

    vm.editEvents = (editing) ->
      AttendanceService.reconcileEvents()
      vm.editingEvents = editing
  ]

  {
    scope:
      cancelRoute: '@'
      editEvents: '&'
    bindToController: true
    controller: AttendanceSetupFormCtrl
    controllerAs: 'setupCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/setup_form.html'
  }
]
