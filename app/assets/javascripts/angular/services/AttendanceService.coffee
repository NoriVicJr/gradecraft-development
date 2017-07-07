@gradecraft.factory 'AttendanceService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  # datesOfWeek = []
  selectedDates = []
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

  postAttendanceArticle = () ->
    # TODO: merge the days of the week info with the other attendance attributes
    $http.post("/api/attendance/new", attendanceAttributes).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  findSelectedDates = () ->
    _dates = []
    _start = angular.copy(attendanceAttributes.startDate)
    _selectedDays = _.pluck(selectedDays(), 'value')

    while _start <= attendanceAttributes.endDate
      _dates.push(angular.copy(_start)) if _start.getDay().toString() in _selectedDays
      _start.setDate(_start.getDate() + 1)

    angular.copy(_dates, selectedDates)

  selectedDays = () ->
    _.filter(daysOfWeek, 'selected')

  {
    selectedDates: selectedDates
    attendanceAttributes: attendanceAttributes
    daysOfWeek: daysOfWeek
    postAttendanceArticle: postAttendanceArticle
    findSelectedDates: findSelectedDates
    selectedDays: selectedDays
  }
]
