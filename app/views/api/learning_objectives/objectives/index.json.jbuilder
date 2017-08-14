json.data @objectives do |objective|
  json.partial! 'api/learning_objectives/objectives/objective', objective: objective
end

json.included do
  json.array! @objectives.map(&:levels).flatten do |level|
    json.type "levels"
    json.id level.id.to_s

    json.attributes do
      json.merge! level.attributes
    end
  end
end

json.meta do
  json.term_for_learning_objective term_for :learning_objective
  json.term_for_learning_objectives term_for :learning_objectives
  json.level_flagged_values LearningObjectiveLevel.flagged_values
end
