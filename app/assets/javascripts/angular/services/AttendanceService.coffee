@gradecraft.factory "AttendanceService", ["$http", "GradeCraftAPI", "DebounceQueue", ($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined
  assignments = []
  attendanceAttributes = {}

  daysOfWeek = [
    { label: "Sunday", value: "0" }
    { label: "Monday", value: "1" }
    { label: "Tuesday", value: "2" }
    { label: "Wednesday", value: "3" }
    { label: "Thursday", value: "4" }
    { label: "Friday", value: "5" }
    { label: "Saturday", value: "6" }
  ]

  lastUpdated = (date) ->
    if angular.isDefined(date) then _lastUpdated = date else _lastUpdated

  getAttendanceAssignments = () ->
    $http.get("/api/attendance").then(
      (response) ->
        GradeCraftAPI.loadMany(assignments, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  queuePostAttendanceEvent = (attendanceEvent) ->
    return if !attendanceEvent.name? or attendanceEvent.isCreating

    if !attendanceEvent.id?
      attendanceEvent.isCreating = true
      _createNewAttendanceEvent(attendanceEvent)
    else
      DebounceQueue.addEvent(
        "attendance_event", attendanceEvent.id, _updateAttendanceEvent, [attendanceEvent]
      )

  _createNewAttendanceEvent = (attendanceEvent) ->
    promise = $http.post("/api/attendance/", { assignment: attendanceEvent })
    _resolveAttendanceResponse(promise, attendanceEvent)

  _updateAttendanceEvent = (attendanceEvent) ->
    promise = $http.put("/api/attendance/#{attendanceEvent.id}", { assignment: attendanceEvent })
    _resolveAttendanceResponse(promise, attendanceEvent)

  _resolveAttendanceResponse = (httpPromise, attendanceEvent) ->
    httpPromise.then(
      (response) ->
        angular.copy(response.data.data.attributes, attendanceEvent)
        lastUpdated(attendanceEvent.updated_at)
        attendanceEvent.isCreating = false
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # Find all applicable dates based on the selected days of the week that are
  # between the specified start and end date and merge with the given times
  reconcileAssignments = () ->
    dates = []
    start = angular.copy(attendanceAttributes.startDate)
    selectedDays = _.filter(daysOfWeek, "selected")

    while start <= attendanceAttributes.endDate
      # Reconcile date with time for each date that is within the date range
      selectedDate = _.find(selectedDays, (day) ->
        start.getDay().toString() == day.value
      )
      if selectedDate?
        dates.push({
          open_at: new Date(start.getFullYear(), start.getMonth(), start.getDate(),
            selectedDate.startTime.getHours(), selectedDate.startTime.getMinutes(),
            selectedDate.startTime.getSeconds()
          )
          due_at: new Date(start.getFullYear(), start.getMonth(), start.getDate(),
            selectedDate.endTime.getHours(), selectedDate.endTime.getMinutes(),
            selectedDate.endTime.getSeconds()
          )
          full_points: if attendanceAttributes.has_points then attendanceAttributes.point_total else null
          pass_fail: !attendanceAttributes.has_points
        })
      start.setDate(start.getDate() + 1)

    angular.copy(dates, assignments)

  {
    assignments: assignments
    attendanceAttributes: attendanceAttributes
    lastUpdated: lastUpdated
    daysOfWeek: daysOfWeek
    getAttendanceAssignments: getAttendanceAssignments
    queuePostAttendanceEvent: queuePostAttendanceEvent
    reconcileAssignments: reconcileAssignments
  }
]
