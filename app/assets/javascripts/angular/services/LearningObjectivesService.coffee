# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', [() ->
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

  _createLearningObjective = (objective) ->
     promise = $http.post("/api/learning_objective/", { learning_objective: objective })
     _resolve(promise, objective)

  _updateLearningObjective = (objective) ->
     promise = $http.put("/api/learning_objective/#{attendanceEvent.id}", { learning_objective: objective })
     _resolve(promise, attendancobjectiveeEvent)

  _resolve = (promise, objective) ->
    promise.then(
      (response) ->
        angular.copy(response.data.data.attributes, objective)
        # lastUpdated(attendanceEvent.updated_at)
        attendanceEvent.isCreating = false
        # attendanceEvent.status = _saveStates.success
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        # attendanceEvent.status = _saveStates.failure
    )

  {
    learningObjectives: learningObjectives
    addLearningObjective: addLearningObjective
    persistLearningObjective: persistLearningObjective
  }
]
