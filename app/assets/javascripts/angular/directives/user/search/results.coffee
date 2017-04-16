# Renders the search results from the user search form
@gradecraft.directive 'userSearchResults', ['UserSearchService', '$sce', (UserSearchService, $sce) ->
  {
    restrict: 'EA'
    templateUrl: 'user/search/results.html'
    link: (scope, element, attr) ->
      scope.users = UserSearchService.users

      # Creates link to allow changing of current course
      scope.course_name_with_link = (user) ->
        $sce.trustAsHtml(_.map(user.course_memberships, (cm) ->
          "<a href='/courses/#{cm.course_id}/change'>#{cm.course_name}</a>"
        ).join("<br>"))

      scope.course_membership_attribute_for = (user, attribute) ->
        $sce.trustAsHtml(_.pluck(user.course_memberships, attribute).join('<br>'))
  }
]
