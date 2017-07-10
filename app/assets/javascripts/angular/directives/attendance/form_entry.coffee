# Initial setup form for creating a new attendance event
# Requires a parent form, since the submit button state is tied to the state of
# the inputs
@gradecraft.directive 'attendanceFormEntry', ['AttendanceService', (AttendanceService) ->
  AttendanceFormEntryCtrl = [() ->
    vm = this

    vm.attributes = AttendanceService.attendanceAttributes
  ]

  {
    scope:
      cancelRoute: '@'
      editEvents: '&'
    bindToController: true
    controller: AttendanceFormEntryCtrl
    controllerAs: 'formEntryCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/form_entry.html'
    require: '^form'  # requires parent form
    link: (scope, el, attr, form) ->
      scope.form = form
  }
]
