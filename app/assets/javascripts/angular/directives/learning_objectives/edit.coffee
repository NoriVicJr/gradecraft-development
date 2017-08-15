# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesEdit', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesEditCtrl = [()->
    vm = this

    vm.loading = true
    vm.objective = LearningObjectivesService.objective
    vm.lastUpdated = LearningObjectivesService.lastUpdated

    services(@objectiveId).then(() ->
      vm.loading = false
    )
  ]

  services = (objectiveId) ->
    promises = [
      LearningObjectivesService.getArticles("categories"),
      LearningObjectivesService.getObjective(objectiveId)
    ]
    $q.all(promises)

  {
    scope:
      objectiveId: '@'
      deleteRoute: '@'
    bindToController: true
    controller: LearningObjectivesEditCtrl
    controllerAs: 'loEditCtrl'
    templateUrl: 'learning_objectives/edit.html'
  }
]
