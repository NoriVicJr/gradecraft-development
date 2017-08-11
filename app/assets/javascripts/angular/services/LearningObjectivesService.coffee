# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', ['$http', 'GradeCraftAPI', 'DebounceQueue', ($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined

  levels = []
  objectives = []
  categories = []

  addObjective = () ->
    objectives.push(
      name: undefined
      description: undefined
      countToAchieve: undefined
    )

  addCategory = () ->
    categories.push(
      name: undefined
      allowable_yellow_warnings: undefined
    )

  addLevel = (objectiveId) ->
    levels.push(
      objective_id: objectiveId
      name: undefined
      description: undefined
      flagged_value: 1
    )

  getArticles = (type) ->
    $http.get("/api/learning_objectives/#{type}").then(
      (response) ->
        arr = if type == "objectives" then objectives else categories
        arr.length = 0
        GradeCraftAPI.loadMany(arr, response.data)
        GradeCraftAPI.setTermFor("learning_objective", response.data.meta.term_for_learning_objective)
        GradeCraftAPI.setTermFor("learning_objectives", response.data.meta.term_for_learning_objectives)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  persistArticle = (article, type) ->
    return if !article.name? || article.isCreating

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type)
    else
      DebounceQueue.addEvent(
        type, article.id, _updateArticle, [article, type]
      )

  # Route: /api/learning_objectives/#{association}/#{associationId}/#{type}
  # e.g. /api/learning_objectives/objectives/1/levels
  persistAssociatedArticle = (association, associationId, article, type) ->
    debugger
    return if !article.name? || article.isCreating
    routePrefix = "/api/learning_objectives/#{association}/#{associationId}"

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type, routePrefix)
    else
      DebounceQueue.addEvent(
        type, article.id, _updateArticle, [article, type, routePrefix]
      )

  deleteArticle = (article, type) ->
    arr = if type == "objectives" then objectives else categories
    return arr.splice(arr.indexOf(article), 1) if !article.id?

    if confirm "Are you sure you want to delete #{article.name}?"
      $http.delete("/api/learning_objectives/#{type}/#{article.id}").then(
        (response) ->
          arr.splice(arr.indexOf(article), 1)
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

  lastUpdated = (date) ->
    if angular.isDefined(date) then _lastUpdated = date else _lastUpdated

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  isSaved = (article) ->
    article.id?

  _createArticle = (article, type, routePrefix="/api/learning_objectives") ->
    promise = $http.post("#{routePrefix}/#{type}", _params(article, type))
    _resolve(promise, article, type)

  _updateArticle = (article, type, routePrefix="/api/learning_objectives") ->
    promise = $http.put("#{routePrefix}/#{type}/#{article.id}", _params(article, type))
    _resolve(promise, article, type)

   _params = (article, type) ->
    params = {}
    term = switch type
      when "objectives" then "learning_objective"
      when "categories" then "learning_objective_category"
      when "levels" then "learning_objective_level"
    params[term] = article
    params

  _resolve = (promise, article, type) ->
    promise.then(
      (response) ->
        angular.copy(response.data.data.attributes, article)
        lastUpdated(article.updated_at)
        article.isCreating = false
        # article.status = _saveStates.success
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        # article.status = _saveStates.failure
    )

  {
    levels: levels
    objectives: objectives
    categories: categories
    addObjective: addObjective
    addCategory: addCategory
    addLevel: addLevel
    getArticles: getArticles
    persistArticle: persistArticle
    persistAssociatedArticle: persistAssociatedArticle
    deleteArticle: deleteArticle
    lastUpdated: lastUpdated
    termFor: termFor
    isSaved: isSaved
  }
]
