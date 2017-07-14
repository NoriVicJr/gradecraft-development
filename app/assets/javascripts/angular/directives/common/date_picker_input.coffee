# Date picker component without time
# Requires datejs (http://www.datejs.com/)
@gradecraft.directive 'gcDateInput', ['$filter', ($filter) ->
  {
    restrict: 'A'
    require: 'ngModel'
    transclude: true
    link: (scope, element, attrs, modelCtrl) ->
      element.datepicker({
        dateFormat: 'DD, MM d, yy'
        onSelect: (date) ->
          modelCtrl.$setViewValue(date)
      })

      # When user input is detected, check that the date is valid
      modelCtrl.$viewChangeListeners.push(() ->
        parsedDate = Date.parseExact(modelCtrl.$viewValue, ['dddd, MMMM d, yyyy'])
        modelCtrl.$setValidity('date', if parsedDate? then true else false)
      )

      # Parse string back to Date on model.
      # This is necessary to make sure that validators are
      # evaluating Dates, not strings
      modelCtrl.$parsers.push((inputValue) ->
        Date.parse(inputValue)
      )

      # Format date as string matching datetimepicker's
      # dateFormat and Timeformat.
      modelCtrl.$formatters.push((inputValue) ->
        $filter('date')(inputValue, 'EEEE, MMMM d, yyyy')
      )
  }
]

# Time picker component without date
# Requires datejs (http://www.datejs.com/)
@gradecraft.directive 'gcTimeInput', ['$filter', ($filter) ->
  {
    restrict: 'A'
    require: 'ngModel'
    transclude: true
    link: (scope, element, attrs, modelCtrl) ->
      element.datetimepicker({
        timeOnly: true
        timeFormat: 'hh:mm TT'
        controlType: 'select'
        onSelect: (date) ->
          modelCtrl.$setViewValue(date)
      })

      # When user input is detected, check that the date is valid
      modelCtrl.$viewChangeListeners.push(() ->
        parsedDate = Date.parseExact(modelCtrl.$viewValue, ['hh:mm tt'])
        modelCtrl.$setValidity('time', if parsedDate? then true else false)
      )

      # Parse string back to Date on model.
      # This is necessary to make sure that validators are
      # evaluating Dates, not strings
      modelCtrl.$parsers.push((inputValue) ->
        Date.parse(inputValue)
      )

      # Format date as string matching datetimepicker's
      # dateFormat and Timeformat.
      modelCtrl.$formatters.push((inputValue) ->
        $filter('date')(inputValue, 'hh:mm a')
      )
  }
]
