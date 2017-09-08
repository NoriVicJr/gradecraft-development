@gradecraft.directive 'learningObjectivesGradeOverview', ['LearningObjectivesService', 'GradeService', '$q',
(LearningObjectivesService, GradeService, $q) ->
  LearningObjectivesGradeOverviewCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.cumulativeOutcomeFor = (objectiveId) ->
      LearningObjectivesService.cumulativeOutcomeFor(objectiveId)

    vm.observedOutcomeFor = (cumulativeOutcomeId, gradeId) ->
      LearningObjectivesService.observedOutcomesFor(cumulativeOutcomeId, "Grade", gradeId)

    vm.levelSelected = (objectiveId, levelId) ->
      cumulative_outcome = LearningObjectivesService.cumulativeOutcomeFor(objectiveId)
      return false if !cumulative_outcome

      observed_outcome = LearningObjectivesService.observedOutcomesFor(cumulative_outcome.id,
        "Grade", @gradeId)
      return false if !observed_outcome?
      
      observed_outcome.objective_level_id == levelId

    services(@assignmentId).then(() ->
      vm.loading = false
    )
  ]

  services = (assignmentId) ->
    promises = [
      LearningObjectivesService.getArticles("objectives", { assignment_id: @assignmentId }),
      LearningObjectivesService.getOutcomes(assignmentId)
    ]
    $q.all(promises)

  {
    scope:
      assignmentId: '@'
      gradeId: '@'
    bindToController: true
    controller: LearningObjectivesGradeOverviewCtrl
    controllerAs: 'loGradeOverviewCtrl'
    templateUrl: 'learning_objectives/grade_overview.html'
  }
]
