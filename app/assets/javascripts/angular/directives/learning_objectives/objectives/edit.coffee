# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesEdit', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  learningObjectivesObjectivesEditCtrl = [()->
    vm = this

    vm.loading = false
    vm.objective = LearningObjectivesService.objective
    vm.lastUpdated = LearningObjectivesService.lastUpdated

    vm.persistArticle = () ->
      LearningObjectivesService.persistArticle(vm.objective(), "objectives")

    if @objectiveId?
      vm.loading = true
      services(@objectiveId).then(() ->
        vm.loading = false
      )
    else
      LearningObjectivesService.addObjective()
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
    controller: learningObjectivesObjectivesEditCtrl
    controllerAs: 'loObjectivesEditCtrl'
    templateUrl: 'learning_objectives/objectives/edit.html'
  }
]
