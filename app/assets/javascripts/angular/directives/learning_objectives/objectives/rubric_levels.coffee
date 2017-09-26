@gradecraft.directive "learningObjectivesRubricLevels", ["LearningObjectivesService", (LearningObjectivesService) ->
  LearningObjectivesRubricLevelsCtrl = [() ->
    vm = this

    vm.levelIsSaved = (level) ->
      LearningObjectivesService.isSaved(level)

    vm.objectiveIsSaved = () ->
      LearningObjectivesService.isSaved(@objective)
  ]

  {
    scope:
      objective: "="
    bindToController: true
    controller: LearningObjectivesRubricLevelsCtrl
    controllerAs: "loRubricLevelsCtrl"
    templateUrl: "learning_objectives/objectives/rubric_levels.html"
    link: (scope, elem, attr) ->
      scope.levels = LearningObjectivesService.levels(scope.loRubricLevelsCtrl.objective)

      scope.sortableOptions = {
        handle: ".draggable-ellipsis"
      }

      scope.deleteLevel = (level) ->
        LearningObjectivesService.deleteAssociatedArticle("objectives", scope.loRubricLevelsCtrl.objective.id, level, "levels", scope.levels)

      scope.addLevel = () ->
        scope.levels.push(LearningObjectivesService.newLevel(scope.loRubricLevelsCtrl.objective.id, scope.levels.length + 1))

      scope.reordering = () ->
        _.some(scope.levels, (level) ->
          !LearningObjectivesService.isSaved(level)
        )

      scope.$watchCollection("levels", (newLevels, oldLevels) ->
        return if scope.reordering()
        LearningObjectivesService.updateOrder(newLevels, scope.loRubricLevelsCtrl.objective.id) if !_.isEqual(newLevels, oldLevels)
      )
  }
]
