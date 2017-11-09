@gradecraft.directive 'learningObjectivesObjectivesTable', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesObjectivesTableCtrl = [() ->
    vm = this
    vm.newObjectivePath = if @category? then "/learning_objectives/objectives/new?category_id=#{@category.id}" else "/learning_objectives/objectives/new"

    vm.objectives = () ->
      LearningObjectivesService.objectives(@category || "uncategorized")

    vm.editObjectivePath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/edit"

    vm.linkedAssignmentsPath = (objectiveId) ->
      "/learning_objectives/objectives/#{objectiveId}/linked_assignments"

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
