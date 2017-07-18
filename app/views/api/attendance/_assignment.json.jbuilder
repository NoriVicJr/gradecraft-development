json.type "assignment"
json.id assignment.id

json.attributes do
  json.id assignment.id
  json.description assignment.description
  json.open_at assignment.open_at
  json.due_at assignment.due_at
  json.assignment_type_id assignment.assignment_type_id
  json.full_points assignment.full_points unless assignment.pass_fail?
  json.name assignment.name
  json.pass_fail assignment.pass_fail
end
