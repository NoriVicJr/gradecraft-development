# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesSetupForm', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesSetupFormCtrl = [()->
    vm = this
    vm.loading = true

    vm.objectives = LearningObjectivesService.objectives
    vm.categories = LearningObjectivesService.categories
    vm.lastUpdated = LearningObjectivesService.lastUpdated

    vm.addObjective = LearningObjectivesService.addObjective
    vm.addCategory = LearningObjectivesService.addCategory

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
    controller: LearningObjectivesSetupFormCtrl
    controllerAs: 'loSetupFormCtrl'
    templateUrl: 'learning_objectives/setup_form.html'
  }
]
