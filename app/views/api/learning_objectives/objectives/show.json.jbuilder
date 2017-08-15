json.data do
  json.partial! 'api/learning_objectives/objectives/objective', objective: @objective
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
