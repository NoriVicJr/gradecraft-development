@gradecraft.directive "learningObjectivesShow", ["LearningObjectivesService", "AssignmentService", "$q", (LearningObjectivesService, AssignmentService, $q) ->
  LearningObjectivesShowCtrl = [() ->
    vm = this
    vm.loading = true
    vm.objective = LearningObjectivesService.objective
    vm.linkedAssignments = LearningObjectivesService.linkedAssignments
    vm.cumulativeOutcomes = LearningObjectivesService.cumulativeOutcomes

    vm.overallProgress = () ->
      LearningObjectivesService.overallProgress(parseInt(vm.objectiveId))

    vm.status = () ->
      LearningObjectivesService.statusFor(vm.objectiveId)

    vm.observedOutcomesFor = (cumulativeId) ->
      LearningObjectivesService.observedOutcomesFor(cumulativeId)

    vm.assignmentNames = (cumulativeId) ->
      _.pluck(vm.observedOutcomesFor(cumulativeId), 'assignment_name')

    vm.gradePaths = (cumulativeId) ->
      oo = vm.observedOutcomesFor(cumulativeId)
      return unless oo?
      _.map(oo, (o) -> "/grades/#{o.id}")

    services(vm.objectiveId).then(() -> vm.loading = false)
  ]

  services = (objectiveId)->
    promises = [
      LearningObjectivesService.getObjective(objectiveId, true),
      LearningObjectivesService.getOutcomesForObjective(objectiveId)
    ]
    return $q.all(promises)

  {
    scope:
      objectiveId: "@"
    bindToController: true
    controller: LearningObjectivesShowCtrl
    controllerAs: "loShowCtrl"
    templateUrl: "learning_objectives/objectives/show.html"
  }
]
