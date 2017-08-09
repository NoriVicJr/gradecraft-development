json.type "learning_objective_category"
json.id category.id

json.attributes do
  json.merge! category.attributes
  json.updated_at category.updated_at
end
