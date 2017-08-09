json.data @objectives do |objective|
  json.partial! 'api/learning_objectives/objectives/objective', objective: objective
end

json.meta do
  json.term_for_learning_objective term_for :learning_objective
  json.term_for_learning_objectives term_for :learning_objectives
end
