@gradecraft.directive 'attendanceEventAttributeCard', ['AttendanceService', '$timeout', (AttendanceService, $timeout) ->
  {
    scope:
      event: '='
    restrict: 'EA'
    templateUrl: 'attendance/_event_attribute_card.html'
    link: (scope, el, attr) ->
      scope.queuePostAttendanceEvent = () ->
        AttendanceService.queuePostAttendanceEvent(@event)
        $timeout(
          () -> scope.event.status = null
        , 6000)

      scope.saveStatusClass = () ->
        switch @event.status.state
          when "saving" then "save-pending"
          when "success" then "save-success"
          else "save-failure"

      scope.editAssignment = () ->
        AttendanceService.editAttendanceEvent(@event)

      scope.deleteEvent = (index) ->
        AttendanceService.deleteAttendanceEvent(@event, index)
  }
]
