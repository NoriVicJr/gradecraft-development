# Main directive for rendering the template and handling any learning objective category logic
@gradecraft.directive 'learningObjectiveCategory', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectiveCategoryCtrl = [()->
    vm = this

    vm.persist = () ->
      LearningObjectivesService.persistArticle(@category, "categories")

    vm.delete = () ->
      LearningObjectivesService.deleteArticle(@category, "categories")

    vm.saved = () ->
      LearningObjectivesService.isSaved(@category)
  ]

  {
    scope:
      category: '='
    bindToController: true
    controller: LearningObjectiveCategoryCtrl
    controllerAs: 'loCategoryCtrl'
    templateUrl: 'learning_objectives/category.html'
  }
]
