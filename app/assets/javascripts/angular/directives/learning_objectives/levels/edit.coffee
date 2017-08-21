# Main directive for rendering the template and handling any learning objective category logic
@gradecraft.directive 'learningObjectivesLevelsEdit', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveLevelsEditCtrl = [() ->
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
    controller: LearningObjectiveLevelsEditCtrl
    controllerAs: 'loLevelsEditCtrl'
    templateUrl: 'learning_objectives/levels/edit.html'
  }
]
