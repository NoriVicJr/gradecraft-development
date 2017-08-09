# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveCtrl = [()->
    vm = this

    vm.persist = () ->
      LearningObjectivesService.persistArticle(@objective, "learning objective")

    vm.delete = (index) ->
      LearningObjectivesService.deleteArticle(@objective, "learning objective", index)
  ]

  {
    scope:
      objective: '='
      learningObjectiveTerm: '@'
    bindToController: true
    controller: LearningObjectiveCtrl
    controllerAs: 'loCtrl'
    templateUrl: 'learning_objectives/objective.html'
  }
]
