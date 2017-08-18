# Entry point for a new assignment. Once the assignment is
# created, the edit form is disiplayed
@gradecraft.directive 'assignmentNew', ['AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', '$q', (AssignmentTypeService, AssignmentService, LearningObjectivesService, $q) ->
  AssignmentNewCtrl = [()->
    vmAssignmentNew = this
    vmAssignmentNew.loading = true
    vmAssignmentNew.assignmentCreated = false
    vmAssignmentNew.assignments = AssignmentService.assignments
    vmAssignmentNew.assignmentTypes = AssignmentTypeService.assignmentTypes
    vmAssignmentNew.termFor = AssignmentTypeService.termFor

    services().then(()->
      vmAssignmentNew.loading = false
    )

    vmAssignmentNew.newAssignment = {
      assignment_type_id: null,
      name: null
    }

    vmAssignmentNew.createAssignment = ()->
      AssignmentService.createAssignment(vmAssignmentNew.newAssignment).then(()->
        if AssignmentService.assignments.length
          vmAssignmentNew.assignmentCreated = true
      )
  ]

  services = (id)->
    promises = [
      AssignmentTypeService.getAssignmentTypes(),
      LearningObjectivesService.getArticles("objectives")
    ]
    return $q.all(promises)

  {
    bindToController: true,
    controller: AssignmentNewCtrl,
    controllerAs: 'vmAssignmentNew',
    templateUrl: 'assignments/assignment_new.html',
  }
]
