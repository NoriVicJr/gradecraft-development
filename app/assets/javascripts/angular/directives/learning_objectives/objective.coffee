# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveCtrl = [()->
    vm = this
    vm.categories = LearningObjectivesService.categories(true)

    vm.persist = () ->
      LearningObjectivesService.persistArticle(@objective, "objectives")

    vm.delete = () ->
      LearningObjectivesService.deleteArticle(@objective, "objectives", @deleteRoute)

    vm.termFor = (article) ->
      LearningObjectivesService.termFor(article)

    vm.saved = () ->
      LearningObjectivesService.isSaved(@objective)
  ]

  {
    scope:
      objective: '='
      deleteRoute: '@'
    bindToController: true
    controller: LearningObjectiveCtrl
    controllerAs: 'loCtrl'
    templateUrl: 'learning_objectives/objective.html'
  }
]
