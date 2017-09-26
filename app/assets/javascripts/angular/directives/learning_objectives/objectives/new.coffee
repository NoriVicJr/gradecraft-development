# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesNew', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  learningObjectivesObjectivesNewCtrl = [()->
    vm = this

    vm.loading = true
    vm.objective = LearningObjectivesService.objective
    vm.lastUpdated = LearningObjectivesService.lastUpdated
    vm.categories = LearningObjectivesService.categories

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(vm.objective().id)

    vm.levels = () ->
      LearningObjectivesService.levels(vm.objective())

    vm.saved = () ->
      LearningObjectivesService.isSaved(vm.objective())

    vm.deleteObjective = () ->
      LearningObjectivesService.deleteArticle(vm.objective(), "objectives", @submitRoute)

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    services(@objectiveId).then(() ->
      vm.loading = false
    )
    LearningObjectivesService.addObjective() if !@objectiveId?
  ]

  services = (objectiveId) ->
    promises = [
      LearningObjectivesService.getArticles("categories")
    ]
    promises.push(LearningObjectivesService.getObjective(objectiveId)) if objectiveId?
    $q.all(promises)

  {
    scope:
      objectiveId: '@'
      deleteRoute: '@'
      submitRoute: '@'
      objectivesAwardPoints: '='
    bindToController: true
    controller: learningObjectivesObjectivesNewCtrl
    controllerAs: 'loObjectivesNewCtrl'
    templateUrl: 'learning_objectives/objectives/new.html'
    link: (scope, elem, attrs) ->
      scope.persist = (redirect, immediate=false, form=null) ->
        return if form? and form.$invalid
        redirectUrl = if redirect then scope.loObjectivesNewCtrl.submitRoute else null
        LearningObjectivesService.persistArticle(LearningObjectivesService.objective(), "objectives", redirectUrl, immediate)
  }
]
