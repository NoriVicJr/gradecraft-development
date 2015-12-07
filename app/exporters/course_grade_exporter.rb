class CourseGradeExporter

  #final grades: total score + grade earned in course
  def final_grades_for_course(course)
    CSV.generate do |csv|
      csv.add_row baseline_headers
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.email, student.username, student.cached_score_for_course(course), student.grade_letter_for_course(course)]
      end
    end
  end

  private

  def baseline_headers 
    ["First Name", "Last Name", "Email", "Username", "Score", "Grade" ]
  end

end