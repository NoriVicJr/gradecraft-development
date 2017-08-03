@gradecraft.directive 'attendanceEventAttributes', ['AttendanceService', '$timeout', (AttendanceService, $timeout) ->
  {
    scope:
      disableEdit: '&'
      termForSave: '@'
    controllerAs: 'eventAttrCtrl'
    restrict: 'EA'
    templateUrl: 'attendance/_event_attributes.html'
    link: (scope, el, attr) ->
      scope.events = AttendanceService.events
      scope.lastUpdated = AttendanceService.lastUpdated

      scope.queuePostAttendanceEvent = (event) ->
        AttendanceService.queuePostAttendanceEvent(event)
        $timeout(
          () -> event.status = null
        , 6000)

      scope.saveStatusClass = (event) ->
        switch event.status.state
          when "saving" then "save-pending"
          when "success" then "save-success"
          else "save-failure"

      scope.hasPersistedEvents = () ->
        _.any(scope.events, (a) -> a.id?)

      scope.deleteEvent = (event, index) ->
        AttendanceService.deleteAttendanceEvent(event, index)
  }
]
