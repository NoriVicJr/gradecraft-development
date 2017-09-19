# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesDesign', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesObjectivesDesignCtrl = [() ->
    vm = this

    vm.loading = true
    vm.objectives = LearningObjectivesService.objectives
    vm.lastUpdated = LearningObjectivesService.lastUpdated
    vm.addObjective = LearningObjectivesService.addObjective

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    services(@objectiveId).then(() ->
      vm.loading = false
    )
  ]

  services = (objectiveId) ->
    promises = [
      LearningObjectivesService.getArticles("categories")
    ]
    promises.push(LearningObjectivesService.getObjective(objectiveId)) if objectiveId?
    promises.push(LearningObjectivesService.getArticles("objectives")) if !objectiveId?
    $q.all(promises)

  {
    scope:
      indexRoute: '@'
      objectiveId: '@'
      deleteRoute: '@'
    bindToController: true
    controller: LearningObjectivesObjectivesDesignCtrl
    controllerAs: 'loObjectivesDesignCtrl'
    templateUrl: 'learning_objectives/objectives/design.html'
  }
]
