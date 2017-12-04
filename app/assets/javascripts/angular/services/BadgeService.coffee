# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'BadgeService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', 'DebounceQueue', ($http, GradeCraftAPI, GradeCraftPredictionAPI, DebounceQueue) ->

  badges = []
  earnedBadges = []
  fileUploads = []
  update = {}

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  badgesPredictedPoints = ()->
    total = 0
    _.each(badges,(badge)->
        total += badge.prediction.predicted_times_earned * badge.full_points
      )
    total

  studentEarnedBadgeForGrade = (studentId, badgeId, gradeId)->
    _.find(earnedBadges,{ badge_id: parseInt(badgeId), grade_id: parseInt(gradeId) })

  setBadgeIsUpdating = (badgeId, isUpdating=true)->
    badge = _.find(badges, {id: badgeId})
    badge.isUpdating = isUpdating

  #------ Badge Methods -------------------------------------------------------#

  # GET index list of badges
  # for students includes predictions
  # for faculty using student id, includes badge awards and availability
  getBadges = (studentId)->
    if studentId
      url = '/api/students/' + studentId + '/badges'
    else
      url = '/api/badges'
    $http.get(url).success( (response)->
      GradeCraftAPI.loadMany(badges, response, {"include" : ['prediction']})
      _.each(badges, (badge)->
        # add earned badge count for generic predictor
        badge.earned_badge_count = 0 if !badge.earned_badge_count
        # add null prediction when JSON contains no prediction
        badge.prediction = {predicted_times_earned: badge.earned_badge_count} if !badge.prediction
      )
      GradeCraftAPI.loadFromIncluded(earnedBadges,"earned_badges", response)
      GradeCraftAPI.setTermFor("badges", response.meta.term_for_badges)
      GradeCraftAPI.setTermFor("badge", response.meta.term_for_badge)
      update.predictions = response.meta.allow_updates
    )

  getBadge = (badgeId)->
    $http.get('/api/badges/' + badgeId).then(
      (response)->
        GradeCraftAPI.addItem(badges, "badges", response.data)
        GradeCraftAPI.loadFromIncluded(fileUploads,"file_uploads", response.data)
        GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
        GradeCraftAPI.setTermFor("badge", response.data.meta.term_for_badge)
        GradeCraftAPI.logResponse(response)
      ,(response)->
        GradeCraftAPI.logResponse(response)
    )

  createBadge = (params)->
    $http.post("/api/badges/", badge: params).then(
      (response) ->
        GradeCraftAPI.addItem(badges, "badges", response.data)
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  _updateBadge = (id)->
    badge = _.find(badges, {id: id})
    $http.put("/api/badges/#{id}", badge: badge).then(
      (response) ->
        angular.copy(response.data.data.attributes, badge)
        GradeCraftAPI.formatDates(badge, ["open_at", "due_at", "accepts_submissions_until"])
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  queueUpdateBadge = (id)->
    DebounceQueue.addEvent(
      "badges", id, _updateBadge, [id]
    )

  submitBadge = (id)->
    badge = _.find(badges, {id: id})
    DebounceQueue.cancelEvent("badges", id)
    $http.put("/api/badges/#{id}", badge: badge).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
        window.location = "/badges"
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

#------- Icon and File Methods ---------------------------------------------#

  removeIcon = (id)->
    badge = _.find(badges, {id: id})
    badge.icon = null
    badge.remove_icon = true
    _updateBadge(id)

  postIconUpload = (id, files)->
    iconParams = new FormData()
    iconParams.append('badge[icon]', files[0])
    $http.put("/api/badges/#{id}", iconParams,
      transformRequest: angular.identity,
      headers: { 'Content-Type': undefined }
    ).then(
      (response) ->
        badge = _.find(badges, {id: id})
        angular.copy(response.data.data.attributes, badge)
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  postFileUploads = (id, files)->
    fd = new FormData()
    angular.forEach(files, (file, index)->
      fd.append("file_uploads[]", file)
    )
    $http.post(
      "/api/badges/#{id}/file_uploads",
      fd,
      transformRequest: angular.identity,
      headers: { 'Content-Type': undefined }
    ).then(
      (response)-> # success
        if response.status == 201
          GradeCraftAPI.addItems(fileUploads, "file_uploads", response.data)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  deleteFileUpload = (file)->
    file.deleting = true
    GradeCraftAPI.deleteItem(fileUploads, file)
    $http.delete("/api/badge_files/#{file.id}").then(
      (response)-> # success
        if response.status == 200
          GradeCraftAPI.deleteItem(fileUploads, file)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        file.deleting = false
        GradeCraftAPI.logResponse(response)
    )



  #------ Badge Prediction Methods --------------------------------------------#

  # PUT a badge prediction
  postPredictedBadge = (badge)->
    if update.predictions
      requestParams = {
        "predicted_earned_badge": {
          "badge_id": badge.id,
          "predicted_times_earned": badge.prediction.predicted_times_earned
        }}
      if badge.prediction.id
        GradeCraftPredictionAPI.updatePrediction(badge, '/api/predicted_earned_badges/' + badge.prediction.id, requestParams)
      else
        GradeCraftPredictionAPI.createPrediction(badge, '/api/predicted_earned_badges/', requestParams)

  #------ Earned Badge Methods ------------------------------------------------#

  # currently creates explictly for a student and a grade
  createEarnedBadge = (badgeId, studentId, gradeId, notify=true)->
    setBadgeIsUpdating(badgeId)
    requestParams = {
      "student_id": studentId
      "badge_id": badgeId
      "grade_id": gradeId
      "notify": notify
    }

    $http.post('/api/earned_badges/', requestParams).then(
      (response)-> # success
        if response.status == 201
          GradeCraftAPI.addItem(earnedBadges, "earned_badges", response.data)
        GradeCraftAPI.logResponse(response)
        setBadgeIsUpdating(badgeId, false)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
        setBadgeIsUpdating(badgeId, false)
    )

  deleteEarnedBadge = (earnedBadge)->
    setBadgeIsUpdating(earnedBadge.badge_id)
    $http.delete("/api/earned_badges/#{earnedBadge.id}").then(
      (response)-> # success
        if response.status == 200
          setBadgeIsUpdating(earnedBadge.badge_id, false)
          GradeCraftAPI.deleteItem(earnedBadges, earnedBadge)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        setBadgeIsUpdating(earnedBadge.badge_id, false)
        GradeCraftAPI.logResponse(response)
    )

  notifyEarnedBadges = () ->
    badge_ids = _.pluck(_.filter(badges, "pending_notify"), "id")
    $http.put("/api/earned_badges/notify", badge_ids: badge_ids).then(
      (response) ->
        console.log("Notified #{badge_ids}.length recipients")
      , (response) ->
        console.error("Failed to notify earned badge recipients")
    )

  return {
      termFor: termFor
      getBadges: getBadges
      getBadge: getBadge
      badges: badges

      createBadge: createBadge
      queueUpdateBadge: queueUpdateBadge
      submitBadge: submitBadge

      fileUploads: fileUploads
      removeIcon: removeIcon
      postIconUpload: postIconUpload
      postFileUploads: postFileUploads
      deleteFileUpload: deleteFileUpload

      badgesPredictedPoints: badgesPredictedPoints
      postPredictedBadge: postPredictedBadge

      earnedBadges: earnedBadges
      createEarnedBadge: createEarnedBadge
      deleteEarnedBadge: deleteEarnedBadge
      notifyEarnedBadges: notifyEarnedBadges
      studentEarnedBadgeForGrade: studentEarnedBadgeForGrade
  }
]
