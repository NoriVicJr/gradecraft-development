# Main directive for rendering the template and handling any learning objective-specific logic
@gradecraft.directive 'learningObjectiveLevel', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveLevelCtrl = [()->
    vm = this
    vm.flaggedValues = LearningObjectivesService.levelFlaggedValues

    vm.persist = () ->
      LearningObjectivesService.persistAssociatedArticle("objectives", @level.objective_id, @level, "levels")

    vm.delete = () ->
      LearningObjectivesService.deleteAssociatedArticle("objectives", @level.objective_id, @level, "levels")

    vm.saved = () ->
      LearningObjectivesService.isSaved(@level)
  ]

  {
    scope:
      level: '='
    bindToController: true
    controller: LearningObjectiveLevelCtrl
    controllerAs: 'loLevelCtrl'
    templateUrl: 'learning_objectives/level.html'
  }
]
