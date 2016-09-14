# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'BadgeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  badges = []
  predictions = []
  update = {}

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  badgesPredictedPoints = ()->
    total = 0
    _.each(badges,(badge)->
        total += badge.prediction.predicted_times_earned * badge.full_points
      )
    total

  #------ API Calls -----------------------------------------------------------#

  # GET index list of badges
  # includes a student's earned badges and predictions
  getBadges = (studentId)->
    $http.get(GradeCraftAPI.uriPrefix(studentId) + 'badges').success( (response)->
      GradeCraftAPI.loadMany(badges, response, {"include" : ['prediction']})
      _.each(badges, (badge)->
        # add null prediction when JSON contains no prediction
        badge.prediction = {predicted_times_earned: 0} if !badge.prediction
      )
      #example call to include associated model:
      #GradeCraftAPI.loadFromIncluded(predictions,"predicted_earned_badges", response)
      GradeCraftAPI.setTermFor("badges", response.meta.term_for_badges)
      GradeCraftAPI.setTermFor("badge", response.meta.term_for_badge)
      update.predictions = response.meta.update_predictions
    )

  # PUT a badge prediction
  postPredictedBadge = (badge)->
    if update.predictions
      $http.put(
          '/api/predicted_earned_badges/' + badge.prediction.id, predicted_times_earned: badge.prediction.predicted_times_earned
        ).success(
          (data)->
            console.log(data);
        ).error(
          (data)->
            console.log(data);
        )

  return {
      termFor: termFor
      getBadges: getBadges
      badgesPredictedPoints: badgesPredictedPoints
      postPredictedBadge: postPredictedBadge
      badges: badges
  }
]
