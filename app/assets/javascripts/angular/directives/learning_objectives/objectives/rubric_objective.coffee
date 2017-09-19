@gradecraft.directive 'learningObjectivesRubricObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesRubricObjectiveCtrl = [() ->
    vm = this
    vm.categories = LearningObjectivesService.categories

    vm.persist = () ->
      LearningObjectivesService.persistArticle(@objective, "objectives")

    vm.delete = () ->
      LearningObjectivesService.deleteArticle(@objective, "objectives", @deleteRoute)

    vm.saved = () ->
      LearningObjectivesService.isSaved(@objective)
  ]

  {
    scope:
      objective: "="
      deleteRoute: '='
    bindToController: true
    controller: LearningObjectivesRubricObjectiveCtrl
    controllerAs: 'loRubricObjectivesCtrl'
    templateUrl: 'learning_objectives/objectives/rubric_objective.html'
  }
]
