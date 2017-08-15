# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesMassEdit', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesMassEditCtrl = [()->
    vm = this
    vm.loading = true

    vm.categories = LearningObjectivesService.categories
    vm.lastUpdated = LearningObjectivesService.lastUpdated

    vm.addObjective = LearningObjectivesService.addObjective
    vm.addCategory = LearningObjectivesService.addCategory

    vm.objectives = (category=null) ->
      LearningObjectivesService.objectives(category)

    vm.termFor = (article) ->
      LearningObjectivesService.termFor(article)

    services().then(() ->
      vm.loading = false
    )
  ]

  services = () ->
    promises = [
      LearningObjectivesService.getArticles("categories"),
      LearningObjectivesService.getArticles("objectives")
    ]
    $q.all(promises)

  {
    bindToController: true
    controller: LearningObjectivesMassEditCtrl
    controllerAs: 'loMassEditCtrl'
    templateUrl: 'learning_objectives/edit.html'
  }
]
