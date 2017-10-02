@gradecraft.directive 'learningObjectivesObjectivesTable', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesObjectivesTableCtrl = [() ->
    vm = this
    vm.newObjectivePath = "/learning_objectives/categories/new"

    vm.objectives = () ->
      LearningObjectivesService.objectives(@category)

    vm.editObjectivePath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/edit"

    vm.deleteObjective = (objective) ->
      LearningObjectivesService.deleteArticle(objective, "objectives")

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)
  ]

  {
    scope:
      category: '='
    bindToController: true
    controller: LearningObjectivesObjectivesTableCtrl
    controllerAs: 'loObjectivesTableCtrl'
    templateUrl: 'learning_objectives/components/_objectives_table.html'
  }
]
