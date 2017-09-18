@gradecraft.directive "learningObjectivesRubricLevel", ["LearningObjectivesService", (LearningObjectivesService) ->
  LearningObjectivesRubricLevelCtrl = [() ->
    vm = this
    vm.flaggedValues = LearningObjectivesService.levelFlaggedValues

    vm.persist = () ->
      LearningObjectivesService.persistAssociatedArticle("objectives", @level.objective_id, @level, "levels")

    vm.delete = () ->
      LearningObjectivesService.deleteAssociatedArticle("objectives", @level.objective_id, @level, "levels")

    vm.levelIsSaved = () ->
      LearningObjectivesService.isSaved(@level)
  ]

  {
    scope:
      level: "="
    bindToController: true
    controller: LearningObjectivesRubricLevelCtrl
    controllerAs: "loRubricLevelCtrl"
    templateUrl: "learning_objectives/objectives/rubric_level.html"
  }
]
