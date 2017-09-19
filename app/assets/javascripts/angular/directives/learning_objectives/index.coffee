# Main entry point for viewing all learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesIndex', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesIndexCtrl = [()->
    vm = this
    vm.loading = true

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

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
    scope:
      deleteCategoryPath: '@'
    bindToController: true
    controller: LearningObjectivesIndexCtrl
    controllerAs: 'loIndexCtrl'
    templateUrl: 'learning_objectives/index.html'
  }
]
