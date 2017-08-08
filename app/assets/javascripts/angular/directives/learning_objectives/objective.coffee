# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveCtrl = [()->
    vm = this
    vm.loading = true

    vm.persist = () ->
      LearningObjectivesService.persistLearningObjective(@objective)

    vm.delete = (index) ->
      LearningObjectivesService.deleteLearningObjective(@objective, index)
  ]

  {
    scope:
      objective: '='
    bindToController: true
    controller: LearningObjectiveCtrl
    controllerAs: 'loObjectiveCtrl'
    templateUrl: 'learning_objectives/objective.html'
  }
]
