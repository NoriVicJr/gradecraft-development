# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjective', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveCtrl = [()->
    vm = this
    vm.loading = true

    vm.persist = LearningObjectivesService.persistLearningObjective(@objective)
  ]

  {
    scope:
      objective: '='
    bindToController: true,
    controller: LearningObjectiveCtrl,
    controllerAs: 'loObjectiveCtrl',
    templateUrl: 'learning_objectives/objective.html',
  }
]
