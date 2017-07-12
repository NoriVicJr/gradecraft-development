json.data @assignments do |a|
  json.type "assignment"
  json.id a.id

  json.attributes do
    json.description a.description
    json.open_at a.open_at
    json.due_at a.due_at
    json.assignment_type_id a.assignment_type_id
    json.full_points a.full_points unless a.pass_fail?
    json.name a.name
    json.pass_fail a.pass_fail
  end
end
