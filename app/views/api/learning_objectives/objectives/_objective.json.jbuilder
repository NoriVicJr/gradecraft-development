json.type "learning_objective"
json.id objective.id

json.attributes do
  json.merge! objective.attributes
  json.updated_at objective.updated_at
end
