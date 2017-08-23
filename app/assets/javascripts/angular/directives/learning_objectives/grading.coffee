@gradecraft.directive 'learningObjectivesGrading', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveGradingCtrl = [()->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    vm.levelsFor = (objective) ->
      LearningObjectivesService.levels(objective)

    vm.froalaOptions = {
      heightMin: 100
      placeholderText: 'Enter Feedback for Level...',
    }

    vm.persistOutcome = () ->
      # TODO: persisting outcomes

    LearningObjectivesService.getArticles("objectives", { assignment_id: @assignmentId }).then(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      assignmentId: '='
    bindToController: true
    controller: LearningObjectiveGradingCtrl
    controllerAs: 'loGradingCtrl'
    templateUrl: 'learning_objectives/grading.html'
  }
]
