# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesEdit', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  learningObjectivesObjectivesEditCtrl = [()->
    vm = this

    vm.loading = true
    vm.objective = LearningObjectivesService.objective
    vm.lastUpdated = LearningObjectivesService.lastUpdated
    vm.categories = LearningObjectivesService.categories

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(vm.objective().id)

    vm.levels = () ->
      LearningObjectivesService.levels(vm.objective())

    vm.saved = () ->
      LearningObjectivesService.isSaved(vm.objective())

    vm.persistArticle = () ->
      LearningObjectivesService.persistArticle(vm.objective(), "objectives")

    services(@objectiveId).then(() ->
      vm.loading = false
    )
    LearningObjectivesService.addObjective() if !@objectiveId?
  ]

  services = (objectiveId) ->
    promises = [
      LearningObjectivesService.getArticles("categories")
    ]
    promises.push(LearningObjectivesService.getObjective(objectiveId)) if objectiveId?
    $q.all(promises)

  {
    scope:
      objectiveId: '@'
      deleteRoute: '@'
    bindToController: true
    controller: learningObjectivesObjectivesEditCtrl
    controllerAs: 'loObjectivesEditCtrl'
    templateUrl: 'learning_objectives/objectives/edit.html'
  }
]
