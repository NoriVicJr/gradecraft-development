# buttons to submit grade and redirect on success

@gradecraft.directive 'gradeSubmitButtons', ['GradeService', (GradeService) ->
  {
    scope:
      submitPath: "@"
      gradeNextPath: "@"
    templateUrl: 'grades/submit_buttons.html'
    link: (scope, el, attr) ->
      scope.grade = GradeService.modelGrade
      scope.submitGrade = (returnURL) ->
        GradeService.submitGrade(returnURL)

      scope.textForButton = () ->
        if GradeService.isSetToComplete() then "Submit Grade" else "Save as Draft"

      scope.textForNextButton = () ->
        if GradeService.isSetToComplete() then "Submit and Grade Next" else "Save and Grade Next"

  }
]
