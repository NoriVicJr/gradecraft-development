json.data @assignments do |assignment|
  json.partial! 'api/attendance/assignment', assignment: assignment
end
