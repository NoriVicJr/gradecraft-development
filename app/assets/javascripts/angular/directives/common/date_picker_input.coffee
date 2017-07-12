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

      # Parse string back to Date on model.
      # This is necessary to make sure that validators are
      # evaluating Dates, not strings
      modelCtrl.$parsers.push((inputValue) ->
        # requires datejs (http://www.datejs.com/) to parse date and time
        Date.parse(inputValue)
      )

      # Format date as string matching datetimepicker's
      # dateFormat and Timeformat.
      modelCtrl.$formatters.push((inputValue) ->
        $filter('date')(inputValue, 'EEEE, MMMM d, yyyy')
      )
  }
]
