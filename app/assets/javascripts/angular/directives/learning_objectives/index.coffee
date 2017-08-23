# Main entry point for viewing all learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesIndex', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LearningObjectivesIndexCtrl = [()->
    vm = this
    vm.loading = true

    vm.objectives = () ->
      LearningObjectivesService.objectives()

    vm.categoryName = (objective) ->
      category = LearningObjectivesService.categoryFor(objective)
      category.name if category?

    vm.editObjectivePath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/edit"

    vm.editCategoryPath = (categoryId) ->
      "/learning_objectives/categories/#{categoryId}/edit"

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
    controller: LearningObjectivesIndexCtrl
    controllerAs: 'loIndexCtrl'
    templateUrl: 'learning_objectives/index.html'
  }
]
