# grade adjustment_points input field

@gradecraft.directive 'gradeAdjustmentPointsInput', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/adjustment_points_input.html'
    scope: {
      groupGrade: "=",
    }
    link: (scope, el, attr)->

      scope.assignment = AssignmentService.assignment()
      scope.grades = GradeService.grades

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.froalaOptions = {
        heightMin: 50,
      }
  }
]
