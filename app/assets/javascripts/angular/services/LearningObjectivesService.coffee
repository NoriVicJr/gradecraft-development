# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', ['$http', 'GradeCraftAPI', 'DebounceQueue', ($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined
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

    if !article.id
      article.isCreating = true
      _createArticle(article, type)
    else
      DebounceQueue.addEvent(
        type, article.id, _updateArticle, [article, type]
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

  _createArticle = (article, type) ->
     promise = $http.post("/api/learning_objectives/#{type}", _params(article, type))
     _resolve(promise, article)

  _updateArticle = (article, type) ->
     promise = $http.put("/api/learning_objectives/#{type}/#{article.id}", _params(article, type))
     _resolve(promise, article)

   _params = (article, type) ->
     params = {}
     term = if type == "objectives" then "learning_objective" else "learning_objective_category"
     params[term] = article
     params

  _resolve = (promise, article) ->
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
    objectives: objectives
    categories: categories
    addObjective: addObjective
    addCategory: addCategory
    getArticles: getArticles
    persistArticle: persistArticle
    deleteArticle: deleteArticle
    lastUpdated: lastUpdated
    termFor: termFor
  }
]
