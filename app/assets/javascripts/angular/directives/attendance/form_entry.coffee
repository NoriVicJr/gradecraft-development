# Initial setup form for creating a new attendance event
# Requires a parent form, since the submit button state is tied to the state of
# the inputs
@gradecraft.directive 'attendanceFormEntry', ['AttendanceService', (AttendanceService) ->
  AttendanceFormEntryCtrl = [() ->
    vm = this

    vm.attributes = AttendanceService.attendanceAttributes

    vm.validateDates = (elements...) ->
      startDate = @attributes.startDate
      endDate = @attributes.endDate

      # If start or end date is null, or if start date is greater than end date
      if ((!startDate || !endDate) || startDate.compareTo(endDate) == 1)
        _setValidity(elements, false)
      else
        _setValidity(elements, true)
    ]

  _setValidity = (elements, isValid) ->
    _.each(elements, (element) ->
      element.$setValidity('date', isValid)
    )

  {
    scope:
      cancelRoute: '@'
      enableEdit: '&'
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
