# Initial setup form for creating a new attendance event
# Requires a parent form, since the submit button state is tied to the state of
# the inputs
@gradecraft.directive 'attendanceFormEntry', ['AttendanceService', (AttendanceService) ->
  AttendanceFormEntryCtrl = [() ->
    vm = this

    vm.formErrors = []
    vm.attributes = AttendanceService.eventAttributes
    vm.hasSelectedDays = AttendanceService.hasSelectedDays

    vm.cancel = () ->
      window.location.href = @cancelRoute

    vm.validateForm = () ->
      vm.formErrors.length = 0
      startDate = vm.attributes.startDate
      endDate = vm.attributes.endDate

      if startDate && endDate && startDate.compareTo(endDate) == 1
        vm.formErrors.push("End Date must be after Start Date")

      _.each(AttendanceService.selectedDays(), (day) ->
        if day.startTime && day.endTime && day.startTime.compareTo(day.endTime) in [0,1]
          vm.formErrors.push("(#{day.label}) End Time must be after Start Time")
      )
  ]
  
  {
    scope:
      cancelRoute: '@'
      enableEdit: '&'
    bindToController: true
    controller: AttendanceFormEntryCtrl
    controllerAs: 'formEntryCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/_form_entry.html'
    require: '^form'  # requires parent form
    link: (scope, el, attr, form) ->
      scope.form = form
  }
]
