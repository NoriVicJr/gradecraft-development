# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesCategoriesEdit', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesCategoriesEditCtrl = [()->
    vm = this

    vm.loading = false
    vm.category = LearningObjectivesService.category
    vm.lastUpdated = LearningObjectivesService.lastUpdated

    vm.persistArticle = (immediate=false) ->
      LearningObjectivesService.persistArticle(vm.category(), "categories", @redirectRoute, immediate)

    if @categoryId?
      vm.loading = true
      LearningObjectivesService.getCategory(@categoryId).then(() ->
        vm.loading = false
      )
    else
      LearningObjectivesService.addCategory()
  ]

  {
    scope:
      categoryId: '@'
      redirectRoute: '@'
    bindToController: true
    controller: LearningObjectivesCategoriesEditCtrl
    controllerAs: 'loCategoriesEditCtrl'
    templateUrl: 'learning_objectives/categories/edit.html'
  }
]
