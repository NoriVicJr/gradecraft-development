@gradecraft.directive 'daysOfWeek', [() ->
  DaysOfWeekCtrl = [() ->
    vm = this
    vm.selectedDays = []

    vm.days = [
      { label: "Sunday", value: "0" }
      { label: "Monday", value: "1" }
      { label: "Tuesday", value: "2" }
      { label: "Wednesday", value: "3" }
      { label: "Thursday", value: "4" }
      { label: "Friday", value: "5" }
      { label: "Saturday", value: "6" }
    ]
  ]

  {
    bindToController: true
    controller: DaysOfWeekCtrl
    controllerAs: 'daysOfWeekCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/days_of_week.html'
  }
]
