@gradecraft.factory 'UnlockConditionService', ['$http', 'DebounceQueue', 'GradeCraftAPI', ($http, DebounceQueue, GradeCraftAPI) ->

  unlockableId = null
  unlockableType = null
  courseId = null
  unlockConditions = []
  assignments = []
  assignmentTypes = []
  badges = []

  # generate a unique id to avoid collision on date-pickers
  _uid = 0
  datepickerId = ()->
    return ++_uid

  setDatepickerIds = ()->
    _.each(unlockConditions, (uc)->
      uc.datepickerId = datepickerId()
    )

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  _setTermsFor = (response)->
      return if !response.meta
      _.each(["assignment_types", "assignment_type", "assignments", "assignment", "badges", "badge", "pass", "fail"], (term)->
        if response.meta["term_for_#{term}"]
          GradeCraftAPI.setTermFor(term, response.meta["term_for_#{term}"])
      )


  getUnlockConditions = (id, type) ->
    unlockableId = id
    unlockableType = type
    routeType = if type == "GradeSchemeElement" then "grade_scheme_element" else type.toLowerCase()
    route = "/api/#{routeType}s/#{id}/unlock_conditions"

    $http.get(route).then((response) ->
      GradeCraftAPI.loadMany(unlockConditions, response.data)
      angular.copy(response.data.meta.assignments, assignments)
      angular.copy(response.data.meta.assignment_types, assignmentTypes)
      angular.copy(response.data.meta.badges, badges) if response.data.meta.badges
      _setTermsFor(response.data)
      courseId = response.data.meta.course_id
      setDatepickerIds()
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  addCondition = ()->
    unlockConditions.push(
      "id": null,
      "datepickerId": datepickerId(),
      "unlockable_id": unlockableId,
      "unlockable_type": unlockableType,
      "condition_id": null,
      "condition_type": null,
      "condition_state": null,
      "condition_value": null
      "condition_date": null
    )

  _createCondition = (condition)->
    dateId = condition.datepickerId
    requestParams = {
      "unlock_condition": condition
    }
    $http.post("/api/unlock_conditions", requestParams).then((response) ->
      condition.isUpdating = false
      response.data.data.attributes.datepickerId = dateId
      angular.copy(response.data.data.attributes, condition)
      GradeCraftAPI.logResponse(response)
    , (error)->
       GradeCraftAPI.logResponse(error)
    )

  _updateCondition = (condition)->
    dateId = condition.datepickerId
    requestParams = {
      "unlock_condition": condition
    }
    $http.put("/api/unlock_conditions/#{condition.id}", requestParams).then((response) ->
      response.data.data.attributes.datepickerId = dateId
      angular.copy(response.data.data.attributes, condition)
      GradeCraftAPI.logResponse(response)
    , (error)->
       GradeCraftAPI.logResponse(error)
    )

  removeCondition = (condition)->
    return unlockConditions.splice(-1, 1) if !condition.id
    if confirm("Are you sure you want to delete this condition?")
      $http.delete("/api/unlock_conditions/#{condition.id}").then(
        (response)-> # success
          angular.copy(_.reject(unlockConditions, {id: condition.id}), unlockConditions)
          GradeCraftAPI.logResponse(response)
        ,(response)-> # error
          GradeCraftAPI.logResponse(response)
      )

  queueUpdateCondition = (condition)->
    return if ! conditionIsValid(condition)
    return if condition.isUpdating

    if !condition.id
      condition.isUpdating = true
      DebounceQueue.addEvent(
        "unlocks", 0, _createCondition, [condition], 0
      )
    else
      DebounceQueue.addEvent(
        "unlocks", condition.id, _updateCondition, [condition]
      )

  # We need to remove all other fields when the
  # condition type is changed, to avoid invalid
  # condition configuration
  changeConditionType = (condition)->
    condition.condition_id = null
    condition.condition_value = null
    condition.condition_date = null
    if condition.condition_type == "Badge"
      condition.condition_state = "Earned"
    else if condition.condition_type == "Course"
      condition.condition_state = "Earned"
      condition.condition_id = courseId
    else
      condition.condition_state = null


  conditionIsValid = (condition)->
    return false if !(condition.condition_id && condition.condition_type && condition.condition_state)
    if condition.condition_type == "Badge" || condition.condition_type == "Course" || condition.condition_type == "AssignmentType"
      return false if !condition.condition_value
    return true

  {
    termFor: termFor
    assignments: assignments
    assignmentTypes: assignmentTypes
    badges: badges
    unlockConditions: unlockConditions
    getUnlockConditions: getUnlockConditions
    addCondition: addCondition
    removeCondition: removeCondition
    queueUpdateCondition: queueUpdateCondition
    changeConditionType: changeConditionType
    conditionIsValid: conditionIsValid
  }
]
