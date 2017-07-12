@gradecraft.directive 'attendanceSetupForm', ['AttendanceService', (AttendanceService) ->
  AttendanceSetupFormCtrl = [() ->
    vm = this
    vm.editingEvents = false

    vm.editEvents = (editing) ->
      AttendanceService.reconcileAssignments(@assignmentTypeId)
      vm.editingEvents = editing

    vm.postAttendanceArticle = () ->
      AttendanceService.postAttendanceArticle()
  ]

  {
    scope:
      cancelRoute: '@'
      editEvents: '&'
      assignmentTypeId: '@'
    bindToController: true
    controller: AttendanceSetupFormCtrl
    controllerAs: 'setupCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/setup_form.html'
  }
]
