@gradecraft.directive 'attendanceMassEditForm', ['AttendanceService', (AttendanceService) ->
  AttendanceMassEditCtrl = [() ->
    vm = this

    vm.submit = () ->
      console.log "Good job!"
  ]

  {
    bindToController: true
    controller: AttendanceMassEditCtrl
    controllerAs: 'massEditCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/mass_edit.html'
  }
]
