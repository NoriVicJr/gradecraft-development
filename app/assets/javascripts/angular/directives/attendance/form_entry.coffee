# Initial setup form for creating a new attendance event
# Requires a parent form, since the submit button state is tied to the state of
# the inputs
@gradecraft.directive 'attendanceFormEntry', ['AttendanceService', (AttendanceService) ->
  AttendanceFormEntryCtrl = [() ->
    vm = this

    vm.attributes = AttendanceService.attendanceAttributes

    # affectedElement: the ngmodelcontroller for the input that has just changed
    # elements: any additional linked elements that need their validity reset
    vm.validateDates = (affectedElement, elements...) ->
      _setValidity(elements, true)
      _validateDatetimes(@attributes.startDate, @attributes.endDate, true, affectedElement)

    vm.validateTimes = (day, affectedElement, elements...) ->
      _setValidity(elements, true)
      _validateDatetimes(day.startTime, day.endTime, false, affectedElement)
  ]

  # Ensure that if start date and end date are present, the latter should be
  # before the former.
  # Optionally the two can be validated as not equal to one another
  _validateDatetimes = (start, end, allowEqual, elements...) ->
    return if !start or !end
    equalityArr = if allowEqual then [1] else [0, 1]

    if start.compareTo(end) in equalityArr
      _setValidity(elements, false)
    else
      _setValidity(elements, true)

  _setValidity = (elements, isValid) ->
    _.each(elements, (element) ->
      element.$setValidity('element.$name', isValid)
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
