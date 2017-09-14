@gradecraft.directive 'learningObjectivesGradeOverview', ['LearningObjectivesService', 'GradeService', '$q', '$sce',
(LearningObjectivesService, GradeService, $q, $sce) ->
  LearningObjectivesGradeOverviewCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.overallProgress = (objectiveId) ->
      LearningObjectivesService.overallProgress(objectiveId)

    vm.levelSelected = (objectiveId, levelId) ->
      outcome = vm.observedOutcomeFor(objectiveId)
      return false if !outcome?
      outcome.objective_level_id == levelId

    vm.observedOutcomeFor = (objectiveId) ->
      cumulativeOutcome = LearningObjectivesService.cumulativeOutcomeFor(objectiveId)
      return null if !cumulativeOutcome?
      LearningObjectivesService.observedOutcomesFor(cumulativeOutcome.id, "Grade", @gradeId)

    vm.statusFor = (objectiveId) ->
      cumulativeOutcome = LearningObjectivesService.cumulativeOutcomeFor(objectiveId)
      return null if !cumulativeOutcome?
      cumulativeOutcome.status

    vm.sanitize = (html) ->
      $sce.trustAsHtml(html)

    vm.outcomesPath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/outcomes"

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
