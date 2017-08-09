# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesSetupForm', ['LearningObjectivesService', (LearningObjectivesService) ->
  LearningObjectivesSetupFormCtrl = [()->
    vm = this

    vm.learningObjectives = LearningObjectivesService.learningObjectives
    vm.addObjective = LearningObjectivesService.addLearningObjective
    vm.addCategory = LearningObjectivesService.addLearningObjectiveCategory
  ]

  {
    scope:
      termForLearningObjective: '@'
    bindToController: true
    controller: LearningObjectivesSetupFormCtrl
    controllerAs: 'loSetupFormCtrl'
    templateUrl: 'learning_objectives/setup_form.html'
  }
]
