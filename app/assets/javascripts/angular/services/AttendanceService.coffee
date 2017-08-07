@gradecraft.factory "AttendanceService", ["$http", "GradeCraftAPI", "DebounceQueue", ($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined
  events = []
  eventAttributes = {}

  _saveStates =
    saving:
      message: "Saving event...", state: "saving"
    success:
      message: "Event successfully saved", state: "success"
    failure:
      message: "Failed to save event", state: "failure"

  daysOfWeek = [
    { label: "Sunday", value: "0" }
    { label: "Monday", value: "1" }
    { label: "Tuesday", value: "2" }
    { label: "Wednesday", value: "3" }
    { label: "Thursday", value: "4" }
    { label: "Friday", value: "5" }
    { label: "Saturday", value: "6" }
  ]

  hasSelectedDays = () ->
    _.some(daysOfWeek, "selected")

  lastUpdated = (date) ->
    if angular.isDefined(date) then _lastUpdated = date else _lastUpdated

  getAttendanceEvents = () ->
    $http.get("/api/attendance").then(
      (response) ->
        GradeCraftAPI.loadMany(events, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  editAttendanceEvent = (attendanceEvent) ->
    window.location.href = "/assignments/#{attendanceEvent.id}/edit"

  deleteAttendanceEvent = (attendanceEvent, index) ->
    return events.splice(index, 1) if !attendanceEvent.id?

    if confirm "Are you sure you want to delete this attendance event?"
      $http.delete("/api/attendance/#{attendanceEvent.id}").then(
        (response) ->
          events.splice(index, 1)
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
    # attendanceEvent.status = _saveStates.saving
    promise = $http.post("/api/attendance/", { assignment: attendanceEvent })
    _resolveAttendanceResponse(promise, attendanceEvent)

  _updateAttendanceEvent = (attendanceEvent) ->
    # attendanceEvent.status = _saveStates.saving
    promise = $http.put("/api/attendance/#{attendanceEvent.id}", { assignment: attendanceEvent })
    _resolveAttendanceResponse(promise, attendanceEvent)

  _resolveAttendanceResponse = (httpPromise, attendanceEvent) ->
    httpPromise.then(
      (response) ->
        angular.copy(response.data.data.attributes, attendanceEvent)
        lastUpdated(attendanceEvent.updated_at)
        attendanceEvent.isCreating = false
        attendanceEvent.status = _saveStates.success
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        attendanceEvent.status = _saveStates.failure
    )

  # Find all applicable dates based on the selected days of the week that are
  # between the specified start and end date and merge with the given times
  reconcileEvents = () ->
    dates = []
    start = angular.copy(eventAttributes.startDate)
    selectedDays = _.filter(daysOfWeek, "selected")

    while start <= eventAttributes.endDate
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
          full_points: if eventAttributes.has_points then eventAttributes.point_total else null
          pass_fail: !eventAttributes.has_points
        })
      start.setDate(start.getDate() + 1)

    angular.copy(dates, events)

  {
    events: events
    eventAttributes: eventAttributes
    lastUpdated: lastUpdated
    daysOfWeek: daysOfWeek
    hasSelectedDays: hasSelectedDays
    getAttendanceEvents: getAttendanceEvents
    editAttendanceEvent: editAttendanceEvent
    deleteAttendanceEvent: deleteAttendanceEvent
    queuePostAttendanceEvent: queuePostAttendanceEvent
    reconcileEvents: reconcileEvents
  }
]
