json.total_points @total_points

json.grade_scheme_elements @grade_scheme_elements do |gse|
  json.merge! gse.attributes
  json.name gse.name
end