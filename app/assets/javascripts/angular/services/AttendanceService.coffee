@gradecraft.factory 'AttendanceService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  attendanceAttributes = {}

  postAttendanceArticle = () ->
    $http.post("/api/attendance", attendanceAttributes).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  {
    attendanceAttributes: attendanceAttributes
    postAttendanceArticle: postAttendanceArticle
  }
]
