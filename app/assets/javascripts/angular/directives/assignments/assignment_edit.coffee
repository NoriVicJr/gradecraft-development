# Entry point for editing an assignment
@gradecraft.directive 'assignmentEdit', ['$q', 'AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', ($q, AssignmentTypeService, AssignmentService, LearningObjectivesService) ->
  AssignmentEditCtrl = [()->
    vmAssignmentEdit = this
    vmAssignmentEdit.loading = true

    vmAssignmentEdit.assignments = AssignmentService.assignments

    services(vmAssignmentEdit.assignmentId).then(()->
      vmAssignmentEdit.loading = false
    )
  ]

  services = (id)->
    promises = [
      AssignmentService.getAssignment(id),
      AssignmentTypeService.getAssignmentTypes(),
      LearningObjectivesService.getArticles("objectives")
    ]
    return $q.all(promises)

  {
    bindToController: true,
    controller: AssignmentEditCtrl,
    controllerAs: 'vmAssignmentEdit',
    templateUrl: 'assignments/assignment_edit.html',
    scope: {
      assignmentId: "="
    }
  }
]
