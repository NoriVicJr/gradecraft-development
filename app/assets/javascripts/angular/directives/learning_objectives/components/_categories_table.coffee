@gradecraft.directive 'learningObjectivesCategoriesTable', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesCategoriesTableCtrl = [() ->
    vm = this
    vm.categories = LearningObjectivesService.categories

    vm.editCategoryPath = (categoryId) ->
      "/learning_objectives/categories/#{categoryId}/edit"

    vm.deleteCategory = (category) ->
      LearningObjectivesService.deleteArticle(category,
        "categories",
        @deletePath,
        " This will also delete any linked objectives.")

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)
  ]

  {
    scope:
      deletePath: '@'
    bindToController: true
    controller: LearningObjectivesCategoriesTableCtrl
    controllerAs: 'loCategoriesTableCtrl'
    templateUrl: 'learning_objectives/components/_categories_table.html'
  }
]
