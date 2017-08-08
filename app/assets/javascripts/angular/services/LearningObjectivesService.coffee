# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', ['$http', 'GradeCraftAPI', 'DebounceQueue', ($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined
  learningObjectives = []

  getLearningObjectives = () ->
    # TODO: this

  addLearningObjective = () ->
    learningObjectives.push(
      name: undefined
      description: undefined
      countToAchieve: undefined
    )

  persistLearningObjective = (objective) ->
    return if !objective.name? || objective.isCreating

    if !objective.id
      objective.isCreating = true
      _createLearningObjective(objective)
    else
      DebounceQueue.addEvent(
        "learning_objective", objective.id, _updateLearningObjective, [objective]
      )

  deleteLearningObjective = (objective, index) ->
    return learningObjectives.splice(index, 1) if !objective.id?

    if confirm "Are you sure you want to delete this learning objective?"
      $http.delete("/api/learning_objectives/#{objective.id}").then(
        (response) ->
          learningObjectives.splice(index, 1)
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

  lastUpdated = (date) ->
    if angular.isDefined(date) then _lastUpdated = date else _lastUpdated

  _createLearningObjective = (objective) ->
     promise = $http.post("/api/learning_objectives/", { learning_objective: objective })
     _resolve(promise, objective)

  _updateLearningObjective = (objective) ->
     promise = $http.put("/api/learning_objectives/#{objective.id}", { learning_objective: objective })
     _resolve(promise, objective)

  _resolve = (promise, objective) ->
    promise.then(
      (response) ->
        angular.copy(response.data.data.attributes, objective)
        lastUpdated(objective.updated_at)
        objective.isCreating = false
        # objective.status = _saveStates.success
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        # objective.status = _saveStates.failure
    )

  {
    learningObjectives: learningObjectives
    addLearningObjective: addLearningObjective
    persistLearningObjective: persistLearningObjective
    deleteLearningObjective: deleteLearningObjective
    lastUpdated: lastUpdated
  }
]
