@gradecraft.directive 'assignmentEditDetails', ['AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', (AssignmentTypeService, AssignmentService, LearningObjectivesService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/edit_details.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor
      scope.learningObjectives = LearningObjectivesService.objectives

      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)
  }
]
