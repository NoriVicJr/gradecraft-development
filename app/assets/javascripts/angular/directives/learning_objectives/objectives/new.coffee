# Main entry point for configuring the learning objectives and learning objective
# categories for the current course
@gradecraft.directive 'learningObjectivesObjectivesNew', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  learningObjectivesObjectivesNewCtrl = [()->
    vm = this

    vm.loading = true
    vm.objective = LearningObjectivesService.objective
    vm.lastUpdated = LearningObjectivesService.lastUpdated
    vm.categories = LearningObjectivesService.categories

    vm.froalaOptions = {
      width: 800
      heightMin: 200
      placeholderText: "Enter a description"
    }

    vm.hasCategories = () ->
      _.any(vm.categories())

    vm.addLevel = () ->
      LearningObjectivesService.addLevel(vm.objective().id)

    vm.levels = () ->
      LearningObjectivesService.levels(vm.objective())

    vm.saved = () ->
      LearningObjectivesService.isSaved(vm.objective())

    vm.termFor = (term) ->
      LearningObjectivesService.termFor(term)

    services().then(() ->
      vm.loading = false
    )
    LearningObjectivesService.addObjective(@categoryId)
  ]

  services = () ->
    promises = [
      LearningObjectivesService.getArticles("categories")
    ]
    $q.all(promises)

  {
    scope:
      categoryId: '='
      submitRoute: '@'
      objectivesAwardPoints: '='
    bindToController: true
    controller: learningObjectivesObjectivesNewCtrl
    controllerAs: 'loObjectivesNewCtrl'
    templateUrl: 'learning_objectives/objectives/new.html'
    link: (scope, elem, attrs) ->
      scope.persistChanges = () ->
        return if form? and form.$invalid
        LearningObjectivesService.runAllEvents(scope.loObjectivesNewCtrl.submitRoute)

      scope.persist = (redirect, immediate=false, form=null) ->
        return if form? and form.$invalid
        redirectUrl = if redirect then scope.loObjectivesNewCtrl.submitRoute else null
        LearningObjectivesService.persistArticle(LearningObjectivesService.objective(), "objectives", redirectUrl, immediate)
  }
]
