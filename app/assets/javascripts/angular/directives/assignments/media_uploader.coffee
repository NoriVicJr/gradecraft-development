@gradecraft.directive 'assignmentMediaUploader', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignment: "="
      hideAttachments: '@'
    }
    templateUrl: 'assignments/media_uploader.html',
    link: (scope, element, attrs)->
      scope.fileUploads = AssignmentService.fileUploads

      scope.removeMedia = ()->
        AssignmentService.removeMedia(@assignment.id)

      scope.deleteFile = (file)->
        AssignmentService.deleteFileUpload(file)
  }
]

@gradecraft.directive('mediaUpload', ['$parse', 'AssignmentService', ($parse, AssignmentService)->
  return {
    restrict: 'A',
    scope: {
      assignmentId : "="
    }
    link: (scope, element, attrs)->
      model = $parse(attrs.mediaUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          AssignmentService.postMediaUpload(scope.assignmentId, element[0].files)
        )
      )
    }
])

@gradecraft.directive('assignmentFileUpload', ['$parse', 'AssignmentService', ($parse, AssignmentService)->
  return {
    restrict: 'A',
    scope: {
      assignmentId : "="
    }
    link: (scope, element, attrs)->
      model = $parse(attrs.assignmentFileUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          AssignmentService.postFileUploads(scope.assignmentId, element[0].files)
        )
      )
    }
])
