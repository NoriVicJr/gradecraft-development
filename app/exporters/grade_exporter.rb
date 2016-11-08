class GradeExporter

  def export_grades(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.email,
                grade.score || "",
                grade.feedback || ""]
      end
    end
  end

  def export_group_grades(assignment, groups, options={})
    CSV.generate(options) do |csv|
      csv << group_headers
      groups.each do |group|
        grade = group.grade_for_assignment(assignment)
        csv << [group.name,
                grade.score || "",
                grade.feedback || ""]
      end
    end
  end

  def export_grades_with_detail(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers + detail_headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        grade = Grade.new if !(grade.instructor_modified? || grade.graded_or_released?)
        submission = student.submission_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.email,
                grade.score || "",
                grade.feedback || "",
                grade.raw_points || "",
                submission.try(:text_comment) || "",
                grade.graded_at || ""]
      end
    end
  end

  private

  def group_headers
    ["Group Name", "Score", "Feedback"].freeze
  end

  def headers
    ["First Name", "Last Name", "Email", "Score", "Feedback"].freeze
  end

  def detail_headers
    ["Raw Score", "Statement", "Last Updated"].freeze
  end
end
