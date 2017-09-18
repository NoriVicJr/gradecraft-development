@gradecraft.directive 'learningObjectivesRubricLevels', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesRubricLevelsCtrl = [() ->
    vm = this

    vm.levels = () ->
      LearningObjectivesService.levels(@objective)

    vm.levelIsSaved = (level) ->
      LearningObjectivesService.isSaved(level)

    vm.objectiveIsSaved = () ->
      LearningObjectivesService.isSaved(@objective)

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(@objective.id)
  ]

  {
    scope:
      objective: "="
    bindToController: true
    controller: LearningObjectivesRubricLevelsCtrl
    controllerAs: 'loRubricLevelsCtrl'
    templateUrl: 'learning_objectives/objectives/rubric_levels.html'
  }
]
