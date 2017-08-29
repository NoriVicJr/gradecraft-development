# @gradecraft.factory "LearningObjectivesGradingService", ["$http", "GradeCraftAPI", "DebounceQueue", ($http, GradeCraftAPI, DebounceQueue) ->
#
#   # _grades = GradeService.grades
#   outcomes = []
#
#   outcome = (id) ->
#     _.find(outcomes, { id: id })
#
#   # Grade id(s), singular if individually graded; else multiple
#   # getOutcomes = () ->
#   #   _gradeIds = _.pluck(_grades, 'id')
#   #   $http.get("/api/learning_objectives/outcomes", params: { grade_id: _gradeIds }).then(
#   #     (response) ->
#   #       GradeCraftAPI.loadMany(outcomes, response.data)
#   #       GradeCraftAPI.logResponse(response)
#   #     , (response) ->
#   #       GradeCraftAPI.logResponse(response)
#   #   )
#
#   # Scenario 1: Assignment is individually-graded; update the one outcome
#   # Scenario 2: Assignment id group-graded; update all outcomes for each of the
#   # group members
#   persistOutcome = (objectiveId, levelId, recipientId, recipientType) ->
#     console.warn("TODO")
#
#   # persistOutcome = (gradeIds) ->
#   #   if !outcome.id?
#   #     outcome.isCreating = true
#   #     _createOutcome(gradeIds)
#   #   else
#   #     DebounceQueue.addEvent(
#   #       "learning_objective_observed_outcomes", outcome.id, _updateOutcome, [gradeIds]
#   #     )
#
#   _createOutcome = (objectiveId, levelId, gradeIds) ->
#     debugger
#     outcomes = outcome() || _learningObjectiveOutcome(objectiveId, levelId)
#     $http.post("/api/learning_objectives/outcomes", _params(gradeIds)).then(
#       (response) ->
#         GradeCraftAPI.loadItem(outcome, "learning_objective_observed_outcome", response.data)
#         outcome.isCreating = false
#         GradeCraftAPI.logResponse(response)
#       , (response) ->
#         GradeCraftAPI.logResponse(response)
#     )
#
#   _updateOutcome = (gradeIds) ->
#     # $http.put("/api/learning_objectives/outcomes/#{outcome.id}", _params(gradeIds)).then(
#     #
#     # )
#     console.warn("TODO")
#
#   _learningObjectiveOutcome = (objectiveId, levelId) ->
#     {
#       objective_id: objectiveId
#       objective_level_id: levelId
#       gradeId: gradeId
#     }
#
#   _params = (gradeIds) ->
#     {
#       learning_objective_observed_outcome: outcome()
#       grade_ids: gradeIds
#     }
#
#   {
#     outcome: outcome
#     persistOutcome: persistOutcome
#   }
# ]
