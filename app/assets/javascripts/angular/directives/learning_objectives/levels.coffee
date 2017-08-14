# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjectiveLevels', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveLevelsCtrl = [()->
    vm = this

    vm.levels = () ->
      LearningObjectivesService.levels(@objective)

    vm.add = () ->
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
