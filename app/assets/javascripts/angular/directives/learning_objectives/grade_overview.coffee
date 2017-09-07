@gradecraft.directive 'learningObjectivesGradeOverview', ['LearningObjectivesService', 'GradeService', (LearningObjectivesService, GradeService) ->
  LearningObjectivesGradeOverviewCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.outcomeFor = (objectiveId) ->
      GradeService.findOutcome(objectiveId) || GradeService.addOutcome(objectiveId)

    vm.levelSelected = (objectiveId, levelId) ->
      outcome = GradeService.findOutcome(objectiveId)
      return false if !outcome?
      outcome.objective_level_id == levelId

    LearningObjectivesService.getArticles("objectives", { assignment_id: @assignmentId }).then(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      assignmentId: '='
    bindToController: true
    controller: LearningObjectivesGradeOverviewCtrl
    controllerAs: 'loGradeOverviewCtrl'
    templateUrl: 'learning_objectives/grade_overview.html'
  }
]
