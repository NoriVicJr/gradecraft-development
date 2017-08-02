@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', (AttendanceService) ->
  {
    scope:
      disableEdit: '&'
      termForSave: '@'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/_event_attributes.html'
    link: (scope, el, attr) ->
      scope.assignments = AttendanceService.assignments
      scope.lastUpdated = AttendanceService.lastUpdated

      scope.queuePostAttendanceEvent = (assignment) ->
        AttendanceService.queuePostAttendanceEvent(assignment)

      scope.hasAssignments = () ->
        scope.assignments.length > 0

      scope.hasPersistedElements = () ->
        _.any(scope.assignments, (a) -> a.id?)

      scope.deleteAssignment = (assignment, index) ->
        if assignment.id? then assignment._destroy = true else scope.assignments.splice(index, 1)
  }
]
