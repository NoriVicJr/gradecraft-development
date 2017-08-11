json.type "learning_objective_level"
json.id level.id

json.attributes do
  json.merge! level.attributes
  json.updated_at level.updated_at
end
