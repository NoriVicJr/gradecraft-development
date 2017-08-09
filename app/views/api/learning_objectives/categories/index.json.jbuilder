json.data @categories do |category|
  json.partial! 'api/learning_objectives/categories/category', category: category
end

json.meta do
  json.term_for_learning_objective term_for :learning_objective
  json.term_for_learning_objectives term_for :learning_objectives
end
