json.data do
  json.type "learning_objective_observed_outcome"
  json.id @outcome.id

  json.attributes do
    json.merge! @outcome.attributes
  end
end
