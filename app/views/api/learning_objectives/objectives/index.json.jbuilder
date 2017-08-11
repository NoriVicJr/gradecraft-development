json.data @objectives do |objective|
  json.partial! 'api/learning_objectives/objectives/objective', objective: objective

  json.levels objective.levels do |level|
    json.partial! 'api/learning_objectives/levels/level', level: level
  end if objective.levels.any?
end

json.meta do
  json.term_for_learning_objective term_for :learning_objective
  json.term_for_learning_objectives term_for :learning_objectives
end
