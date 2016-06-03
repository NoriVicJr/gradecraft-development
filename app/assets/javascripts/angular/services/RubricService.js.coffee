@gradecraft.factory 'RubricService', ['CourseBadge', 'Criterion', 'CriterionGrade', '$http', (CourseBadge, Criterion, CriterionGrade, $http) ->

  pointsPossible = 0
  thresholdPoints = 0
  assignment = {}
  grade = {}

  gradeStatusOptions = []
  criteria = []

  # TODO standardize to array
  badges = {}
  criterionGrades = {}

  # TODO: $scope should not be passed around if we want to avoid tight coupling
  getCriteria = (assignmentId, $scope)->
    _scope = $scope
    $http.get('/api/assignments/' + assignmentId + '/criteria').success((res)->
      angular.forEach(res.data, (criterion, index)->
        criterionObject = new Criterion(criterion.attributes, _scope)
        criteria.push criterionObject
      )
    )

  addCriterionGrades = (resData)->
    angular.forEach(resData, (cg, index)->
      criterionGrade = cg.attributes
      criterionGrades[cg.attributes.criterion_id] = criterionGrade
    )

  getCriterionGrades = (assignment)->
    if assignment.scope.type == "student"
      $http.get('/api/assignments/' + assignment.id + '/students/' + assignment.scope.id + '/criterion_grades/').success((res)->
        addCriterionGrades(res.data)
      )
    else if assignment.scope.type == "group"
      $http.get('/api/assignments/' + assignment.id + '/groups/' + assignment.scope.id + '/criterion_grades/').success((res)->

        # The API sends all student information so we can add the ability to custom grade group members
        # For now we filter to the first student's grade since all students grades are identical
        addCriterionGrades(_.filter(res.data, { attributes: { 'student_id': res.meta.student_ids[0] }}))
      )

  getBadges = ()->
    $http.get('/api/badges').success((res)->
      angular.forEach(res.data, (badge, index)->
        courseBadge = new CourseBadge(badge.attributes)
        badges[badge.id] = courseBadge
      )
    )

  getGrade = (assignment)->
    if assignment.scope.type == "student"
      $http.get('/api/assignments/' + assignment.id + '/students/' + assignment.scope.id + '/grade/').success((res)->
        angular.copy(res.data.attributes, grade)
        angular.copy(res.meta.grade_status_options, gradeStatusOptions)
        thresholdPoints = res.meta.threshold_points
      )
    else if assignment.scope.type == "group"
      $http.get('/api/assignments/' + assignment.id + '/groups/' + assignment.scope.id + '/grades/').success((res)->

        # The API sends all student information so we can add the ability to custom grade group members
        # For now we filter to the first student's grade since all students grades are identical
        angular.copy(_.find(res.data, { attributes: {'student_id' : res.meta.student_ids[0] }}).attributes, grade)
        angular.copy(res.meta.grade_status_options, gradeStatusOptions)
        thresholdPoints = res.meta.threshold_points
      )

  putRubricGradeSubmission = (assignment, params, returnURL)->
    scopeRoute = if assignment.scope.type == "student" then "students" else "groups"
    $http.put("/api/assignments/#{assignment.id}/#{scopeRoute}/#{assignment.scope.id}/criterion_grades", params).success(
      (data)->
        console.log(data)
        window.location = returnURL
    ).error(
      (data)->
        if data.errors.length
          console.log(data.errors[0].detail)
    )

  thresholdPoints = ()->
    thresholdPoints

  pointsPossible = ()->
    points = 0
    _.map(criteria, (criterion)->
      points += criterion.max_points
    )
    points

  return {
      getCriteria: getCriteria,
      getCriterionGrades: getCriterionGrades,
      getBadges: getBadges,
      getGrade: getGrade,
      putRubricGradeSubmission: putRubricGradeSubmission,
      assignment: assignment,
      badges: badges,
      criteria: criteria,
      criterionGrades: criterionGrades,
      grade: grade,
      gradeStatusOptions: gradeStatusOptions,
      pointsPossible: pointsPossible,
      thresholdPoints: thresholdPoints
  }
]
