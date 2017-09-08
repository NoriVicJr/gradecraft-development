# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', ['$http', 'GradeCraftAPI', 'DebounceQueue',
($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined

  _levels = []
  _objectives = []
  _categories = []
  _cumulative_outcomes = []
  _observed_outcomes = []
  levelFlaggedValues = {}

  objective = () ->
    _objectives[0]

  category = () ->
    _categories[0]

  cumulativeOutcomeFor = (objectiveId) ->
    _.find(_cumulative_outcomes, { learning_objective_id: objectiveId })

  observedOutcomesFor = (cumulativeOutcomeId, type=null, id=null) ->
    criteria = { learning_objective_cumulative_outcomes_id: cumulativeOutcomeId }
    # If filtering down to a specific assessable type (e.g. for a specific grade)
    if type? and id?
      criteria.learning_objective_assessable_type = type
      criteria.learning_objective_assessable_id = id
      _.find(_observed_outcomes, criteria)
    else
      _.filter(_observed_outcomes, criteria)

  levels = (objective) ->
    _.filter(_levels, { objective_id: objective.id })

  objectives = (category=null) ->
    if category? then _.filter(_objectives, { category_id: category.id }) else _objectives

  categories = (savedOnly=false) ->
    if savedOnly then _.filter(_categories, "id") else _categories

  addObjective = () ->
    _objectives.push(
      name: undefined
      description: undefined
      countToAchieve: undefined
      category_id: null
    )

  addCategory = () ->
    _categories.push(
      name: undefined
      allowable_yellow_warnings: undefined
    )

  addLevel = (objectiveId) ->
    _levels.push(
      objective_id: objectiveId
      name: undefined
      description: undefined
      flagged_value: 1
    )

  getOutcomes = (assignmentId) ->
    $http.get("/api/learning_objectives/outcomes", { params: { assignment_id: assignmentId } }).then(
      (response) ->
        GradeCraftAPI.loadMany(_cumulative_outcomes, response.data)
        GradeCraftAPI.loadFromIncluded(_observed_outcomes, "learning_objective_observed_outcome", response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getObjective = (id) ->
    $http.get("/api/learning_objectives/objectives/#{id}").then(
      (response) ->
        GradeCraftAPI.addItem(_objectives, "learning_objective", response.data)
        GradeCraftAPI.loadFromIncluded(_levels, "levels", response.data)
        angular.copy(response.data.meta.level_flagged_values, levelFlaggedValues)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getCategory = (id) ->
    $http.get("/api/learning_objectives/categories/#{id}").then(
      (response) ->
        GradeCraftAPI.addItem(_categories, "learning_objective_category", response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # GET objectives or categories
  # Objectives are expected to come with associated levels
  getArticles = (type, options={}) ->
    $http.get("/api/learning_objectives/#{type}", { params: options }).then(
      (response) ->
        arr = if type == "objectives" then _objectives else _categories
        arr.length = 0
        GradeCraftAPI.loadMany(arr, response.data)
        if type == "objectives"
          GradeCraftAPI.loadFromIncluded(_levels, "levels", response.data)
          angular.copy(response.data.meta.level_flagged_values, levelFlaggedValues)
        GradeCraftAPI.setTermFor("learning_objective", response.data.meta.term_for_learning_objective)
        GradeCraftAPI.setTermFor("learning_objectives", response.data.meta.term_for_learning_objectives)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # POST/PUT articles such as learning objectives, categories
  persistArticle = (article, type, redirectUrl=null, immediate=false) ->
    return if !article.name? || article.isCreating

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type)
    else
      if immediate
        _updateArticle(article, type, null, redirectUrl)
      else
        DebounceQueue.addEvent(
          type, article.id, _updateArticle, [article, type]
        )

  # POST/PUT associated data such as learning objective levels
  # Route: /api/learning_objectives/#{association}/#{associationId}/#{type}
  # e.g. /api/learning_objectives/objectives/1/levels
  persistAssociatedArticle = (association, associationId, article, type) ->
    return if !article.name? || article.isCreating
    routePrefix = "/api/learning_objectives/#{association}/#{associationId}"

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type, routePrefix)
    else
      DebounceQueue.addEvent(
        type, article.id, _updateArticle, [article, type, routePrefix]
      )

  # DELETE articles such as learning objectives, categories
  deleteArticle = (article, type, redirectUrl=null) ->
    arr = if type == "objectives" then _objectives else _categories
    return arr.splice(arr.indexOf(article), 1) if !article.id?

    if confirm "Are you sure you want to delete #{article.name}?"
      $http.delete("/api/learning_objectives/#{type}/#{article.id}").then(
        (response) ->
          arr.splice(arr.indexOf(article), 1)
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

  # DELETE associated articles such as learning objective levels
  deleteAssociatedArticle = (association, associationId, article, type) ->
    return _levels.splice(_levels.indexOf(article), 1) if !article.id?

    if confirm "Are you sure you want to delete #{article.name}?"
      $http.delete("/api/learning_objectives/#{association}/#{associationId}/#{type}/#{article.id}").then(
        (response) ->
          _levels.splice(_levels.indexOf(article), 1)
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

  categoryFor = (objective) ->
    _.find(_categories, { id: objective.category_id })

  _createArticle = (article, type, routePrefix="/api/learning_objectives") ->
    promise = $http.post("#{routePrefix}/#{type}", _params(article, type))
    _resolve(promise, article, type)

  _updateArticle = (article, type, routePrefix="/api/learning_objectives", redirectUrl=null) ->
    promise = $http.put("#{routePrefix}/#{type}/#{article.id}", _params(article, type))
    _resolve(promise, article, type, redirectUrl)

   _params = (article, type) ->
    params = {}
    term = switch type
      when "objectives" then "learning_objective"
      when "categories" then "learning_objective_category"
      when "levels" then "learning_objective_level"
    params[term] = article
    params

  _resolve = (promise, article, type, redirectUrl) ->
    promise.then(
      (response) ->
        angular.copy(response.data.data.attributes, article)
        lastUpdated(article.updated_at)
        article.isCreating = false
        window.location.href = redirectUrl if redirectUrl?
        # article.status = _saveStates.success
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        alert("An unexpected error occurred while saving")
        # article.status = _saveStates.failure
    )

  {
    levels: levels
    objectives: objectives
    categories: categories
    levelFlaggedValues: levelFlaggedValues
    objective: objective
    category: category
    cumulativeOutcomeFor: cumulativeOutcomeFor
    observedOutcomesFor: observedOutcomesFor
    addObjective: addObjective
    addCategory: addCategory
    addLevel: addLevel
    getOutcomes: getOutcomes
    getObjective: getObjective
    getCategory: getCategory
    getArticles: getArticles
    persistArticle: persistArticle
    persistAssociatedArticle: persistAssociatedArticle
    deleteArticle: deleteArticle
    deleteAssociatedArticle: deleteAssociatedArticle
    lastUpdated: lastUpdated
    termFor: termFor
    isSaved: isSaved
    categoryFor: categoryFor
  }
]
