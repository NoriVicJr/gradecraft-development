# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjectiveLevels', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveLevelsCtrl = [()->
    vm = this
    # vm.levels = LearningObjectivesService.levels
    # These levels need to be filtered down by objective

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(@objective.id)
  ]

  {
    scope:
      objective: '='
    bindToController: true
    controller: LearningObjectiveLevelsCtrl
    controllerAs: 'loLevelsCtrl'
    templateUrl: 'learning_objectives/levels.html'
  }
]
