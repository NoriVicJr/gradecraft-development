json.data do
  json.type "learning_objective"
  json.id @objective.id

  json.attributes do
    json.partial! 'api/learning_objectives/objectives/objective', objective: @objective
  end
end

json.included do
  json.array! @objective.levels do |level|
    json.type "levels"
    json.id level.id.to_s

    json.attributes do
      json.merge! level.attributes
    end
  end
end

json.meta do
  json.level_flagged_values LearningObjectiveLevel.flagged_values
end
