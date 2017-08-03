@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', '$timeout', (AttendanceService, $timeout) ->
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
        $timeout(
          () -> assignment.status = null
        , 6000)

      scope.saveStatusClass = (assignment) ->
        switch assignment.status.state
          when "saving" then "save-pending"
          when "success" then "save-success"
          else "save-failure"

      scope.hasAssignments = () ->
        scope.assignments.length > 0

      scope.hasPersistedElements = () ->
        _.any(scope.assignments, (a) -> a.id?)

      scope.deleteAssignment = (assignment, index) ->
        AttendanceService.deleteAttendanceEvent(assignment, index)
  }
]
