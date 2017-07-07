@gradecraft.directive 'daysOfWeek', ['AttendanceService', (AttendanceService) ->
  DaysOfWeekCtrl = [() ->
    vm = this

    vm.days = AttendanceService.daysOfWeek
  ]

  {
    bindToController: true
    controller: DaysOfWeekCtrl
    controllerAs: 'daysOfWeekCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/days_of_week.html'
  }
]
