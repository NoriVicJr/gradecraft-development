@gradecraft.directive 'learningObjectivesRubricObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesRubricObjectiveCtrl = [() ->
    vm = this
    vm.categories = LearningObjectivesService.categories

    vm.persist = () ->
      LearningObjectivesService.persistArticle(@objective, "objectives")

    vm.delete = () ->
      LearningObjectivesService.deleteArticle(@objective, "objectives")

    vm.saved = () ->
      LearningObjectivesService.isSaved(@objective)
  ]

  {
    scope:
      objective: "="
    bindToController: true
    controller: LearningObjectivesRubricObjectiveCtrl
    controllerAs: 'loRubricObjectivesCtrl'
    templateUrl: 'learning_objectives/objectives/rubric_objective.html'
  }
]
