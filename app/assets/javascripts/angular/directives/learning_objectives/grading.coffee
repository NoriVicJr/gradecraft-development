@gradecraft.directive 'learningObjectivesGrading', ['LearningObjectivesService', 'GradeService', (LearningObjectivesService, GradeService) ->
  LearningObjectivesGradingCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.selectLevel = (objectiveId, levelId) ->
      GradeService.setOutcomeLevel(objectiveId, levelId)
      # GradeService.queueUpdateObjectiveOutcome(objectiveId)

    vm.queueUpdateObjectiveOutcome = (objectiveId) ->
      GradeService.queueUpdateObjectiveOutcome(objectiveId)

    vm.outcomeFor = (objectiveId) ->
      GradeService.findOutcome(objectiveId) || GradeService.addOutcome(objectiveId)

    vm.levelSelected = (objectiveId, levelId) ->
      outcome = GradeService.findOutcome(objectiveId)
      return false if !outcome?
      outcome.objective_level_id == levelId

    vm.froalaOptions = {
      heightMin: 100
      placeholderText: 'Enter Feedback for Level...'
    }

    LearningObjectivesService.getArticles("objectives", { assignment_id: @assignmentId }).then(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      assignmentId: '='
    bindToController: true
    controller: LearningObjectivesGradingCtrl
    controllerAs: 'loGradingCtrl'
    templateUrl: 'learning_objectives/grading.html'
  }
]
