@gradecraft.directive 'learningObjectivesObjectivesTable', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesObjectivesTableCtrl = [() ->
    vm = this
    vm.objectives = LearningObjectivesService.objectives

    vm.categoryName = (objective) ->
      category = LearningObjectivesService.categoryFor(objective)
      category.name if category?

    vm.editObjectivePath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/edit"

    vm.editCategoryPath = (categoryId) ->
      "/learning_objectives/categories/#{categoryId}/edit"

    vm.deleteObjective = (objective) ->
      LearningObjectivesService.deleteArticle(objective, "objectives")

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)
  ]

  {
    bindToController: true
    controller: LearningObjectivesObjectivesTableCtrl
    controllerAs: 'loObjectivesTableCtrl'
    templateUrl: 'learning_objectives/components/_objectives_table.html'
  }
]
