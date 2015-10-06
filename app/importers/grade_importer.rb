require 'csv'

class GradeImporter
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  def import(course=nil, assignment=nil)
    if file
      if course && assignment
        students = course.students
        CSV.foreach(file, headers: true, encoding: 'ISO-8859-1') do |csv|
          row = GradeRow.new csv

          student = find_student(row, students)
          if student.nil?
            append_unsuccessful row, "Student not found in course"
            next
          end
          if !row.has_grade?
            append_unsuccessful row, "Grade not specified"
            next
          end

          grade = assignment.all_grade_statuses_grade_for_student(student)
          if row.update_grade? grade
            grade = update_grade row, grade
            report row, grade
          elsif grade.present?
            unchanged << grade
          elsif grade.nil?
            grade = create_grade row, assignment, student
            report row, grade
          end
        end
      end
    end

    self
  end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  def assign_grade(row, grade)
    grade.raw_score = row.grade
    grade.feedback = row.feedback
    grade.status = "Graded" if grade.status.nil?
    grade.instructor_modified = true
  end

  def create_grade(row, assignment, student)
    assignment.grades.create do |grade|
      grade.student_id = student.id
      assign_grade row, grade
    end
  end

  def update_grade(row, grade)
    assign_grade row, grade
    grade.save
    grade
  end

  def find_student(row, students)
    message = row.identifier =~ /@/ ? :email : :username
    students.find do |student|
      student.public_send(message).downcase == row.identifier
    end
  end

  def report(row, grade)
    if grade.valid?
      successful << grade
    else
      append_unsuccessful row, grade.errors.full_messages.join(", ")
    end
  end

  class GradeRow
    include QuoteHelper

    attr_reader :data

    def identifier
      remove_smart_quotes(data[2]).downcase if data[2]
    end

    def feedback
      remove_smart_quotes data[4]
    end

    def grade
      remove_smart_quotes(data[3]).to_i if data[3]
    end

    def has_grade?
      grade.present?
    end

    def update_grade?(grade)
      grade.present? &&
        (grade.raw_score != self.grade || grade.feedback != feedback)
    end

    def initialize(data)
      @data = data
    end

    def to_s
      data.to_s
    end
  end
end
