@gradecraft.directive "learningObjectivesRubricLevels", ["LearningObjectivesService", (LearningObjectivesService) ->
  LearningObjectivesRubricLevelsCtrl = [() ->
    vm = this

    vm.levelIsSaved = (level) ->
      LearningObjectivesService.isSaved(level)

    vm.objectiveIsSaved = () ->
      LearningObjectivesService.isSaved(@objective)

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(@objective.id)

    # Duplicated, but currently required since ui-sortable freaks out when
    # ng-model is not bound to something on the current scope
    vm.observableLevels = () ->
      LearningObjectivesService.levels(@objective)
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

      scope.reordering = () ->
        _.some(scope.loRubricLevelsCtrl.observableLevels(), (level) ->
          !LearningObjectivesService.isSaved(level)
        )

      scope.sortableOptions = {
        handle: ".draggable-ellipsis"
      }

      scope.$watchCollection("levels", (newLevels, oldLevels) ->
        return if scope.reordering()
        LearningObjectivesService.updateOrder(newLevels, scope.loRubricLevelsCtrl.objective.id) if !_.isEqual(newLevels, oldLevels)
      )
  }
]
