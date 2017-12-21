observed_outcomes = @cumulative_outcomes.map(&:observed_outcomes).flatten

json.data @cumulative_outcomes do |cumulative_outcome|
  json.type "learning_objective_cumulative_outcome"
  json.id cumulative_outcome.id.to_s

  json.attributes do
    json.merge! cumulative_outcome.attributes
    json.user_full_name cumulative_outcome.user.name
    json.status cumulative_outcome.learning_objective.progress current_user
  end

  json.relationships do
    json.observed_outcomes do
      json.data cumulative_outcome.observed_outcomes do |observed_outcome|
        json.type "learning_objective_observed_outcome"
        json.id observed_outcome.id.to_s
      end
    end
  end
end

json.included do
  json.array! observed_outcomes do |observed_outcome|
    json.type "learning_objective_observed_outcome"
    json.id observed_outcome.id.to_s

    json.attributes do
      json.merge! observed_outcome.attributes
      json.assignment_name observed_outcome.grade.assignment.name unless observed_outcome.grade.nil?
      json.learning_objective_assessable_id observed_outcome.learning_objective_assessable_id.to_s
      json.flagged_value observed_outcome.learning_objective_level.flagged_value
    end
  end
end
