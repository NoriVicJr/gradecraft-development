@gradecraft.directive 'attendanceSetupForm', [() ->
  AttendanceSetupFormCtrl = [() ->
    vm = this

    vm.attendance = {}
  ]

  {
    bindToController: true,
    controller: AttendanceSetupFormCtrl,
    controllerAs: 'vm',
    restrict: 'EA',
    templateUrl: 'attendance/setup_form.html'
  }
]
