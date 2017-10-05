@gradecraft.directive 'learningObjectivesRubricObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesRubricObjectiveCtrl = [() ->
    vm = this
    vm.categories = LearningObjectivesService.categories

    vm.hasCategories = () ->
      _.any(vm.categories())

    vm.delete = () ->
      LearningObjectivesService.deleteArticle(@objective, "objectives", @deleteRoute)

    vm.saved = () ->
      LearningObjectivesService.isSaved(@objective)
  ]

  {
    scope:
      objective: "="
      deleteRoute: '='
      allowDeletion: '='
      objectivesAwardPoints: '='
    require: "?^form" # optionally search for a form on the element or its parents for validation
    bindToController: true
    controller: LearningObjectivesRubricObjectiveCtrl
    controllerAs: 'loRubricObjectivesCtrl'
    templateUrl: 'learning_objectives/objectives/rubric_objective.html'
    link: (scope, elem, attrs, formCtrl) ->
      scope.persist = () ->
        return if formCtrl? and formCtrl.$invalid
        LearningObjectivesService.persistArticle(scope.loRubricObjectivesCtrl.objective, "objectives")
  }
]
