json.data do
  json.type "learning_objective"
  json.id @learning_objective.id

  json.attributes do
    json.merge! @learning_objective.attributes
    json.updated_at @learning_objective.updated_at
  end
end
