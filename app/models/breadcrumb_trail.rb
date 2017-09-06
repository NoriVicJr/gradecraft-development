class BreadcrumbTrail < Croutons::BreadcrumbTrail

  def dashboard
    breadcrumb('Dashboard', dashboard_path)
  end

  def analytics_staff
    dashboard
    breadcrumb('Staff Analytics', analytics_staff_path)
  end

  def analytics_students
    dashboard
    breadcrumb(objects[:course].student_term.pluralize, analytics_students_path)
  end

  def announcements_index
    dashboard
    breadcrumb('Announcements', announcements_path)
  end

  def announcements_new
    announcements_index
    breadcrumb('New Announcement', new_announcement_path)
  end

  def announcements_show
    announcements_index
    breadcrumb(objects[:announcement].title, announcement_path(objects[:announcement]))
  end

  def assignments_index
    dashboard
    breadcrumb(objects[:course].assignment_term.pluralize, assignments_path)
  end

  def assignments_importers_index
    assignments_index
    breadcrumb("Import " + objects[:course].assignment_term.pluralize, assignments_importers_path)
  end

  def assignments_importers_assignments
    assignments_importers_index
    breadcrumb(objects[:provider_name].capitalize + " " + objects[:course].assignment_term.pluralize)
  end

  def assignments_importers_assignments_import_results
    assignments_importers_index
    breadcrumb(objects[:provider_name].capitalize + " " + objects[:course].assignment_term.pluralize, assignments_importer_assignments_path(objects[:provider_name], objects[:course_id]))
  end

  def assignments_importers_csv_import_review
    assignments_importers_csv
    breadcrumb("Review Assignments")
  end

  def assignments_groups_grades_mass_edit
    assignments_index
    breadcrumb("Update Grades")
  end

  def assignments_grades_review
    assignments_index
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb("Review Grades")
  end

  def assignments_importers_csv
    assignments_importers_index
    breadcrumb('CSV')
  end

  def assignments_settings
    assignments_index
    breadcrumb('Settings')
  end

  def assignments_ng_settings
    assignments_index
    breadcrumb('Settings')
  end

  def assignments_show
    assignments_index
    breadcrumb(objects[:assignment].name)
  end

  def assignments_edit
    assignments_index
    breadcrumb('Editing ' + objects[:assignment].name)
  end

  def assignments_new
    assignments_index
    breadcrumb('New ' +  objects[:course].assignment_term)
  end

  def assignments_grades_mass_edit
    assignments_index
    breadcrumb('Quick Grading ' + objects[:assignment].name)
  end

  def assignment_types_index
    dashboard
    breadcrumb(objects[:course].assignment_term + ' Type Analytics')
  end

  def assignment_types_new
    assignments_index
    breadcrumb('New ' + objects[:course].assignment_term + ' Type')
  end

  def assignment_types_edit
    dashboard
    breadcrumb(objects[:course].assignment_term.pluralize, assignments_path)
    breadcrumb('Editing ' + objects[:assignment_type].name)
  end

  def assignments_groups_grade
    breadcrumb('Dashboard', dashboard_path)
    breadcrumb(objects[:course].assignment_term.pluralize, assignments_path)
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb('Editing ' + objects[:course].group_term + ' Grade')
  end

  def badges_index
    dashboard
    breadcrumb(objects[:course].badge_term.pluralize, badges_path)
  end

  def badges_edit
    badges_index
    breadcrumb('Editing ' + objects[:badge].name)
  end

  def badges_show
    badges_index
    breadcrumb(objects[:badge].name, badge_path(objects[:badge]))
  end

  def badges_new
    badges_index
    breadcrumb('New ' + objects[:course].badge_term)
  end

  def badges_importers_index
    badges_show
    breadcrumb('Badge Import', badge_badges_importers_path(objects[:badge]))
  end

  def badges_importers_csv
    badges_importers_index
    breadcrumb('CSV')
  end

  def badges_importers_import_results
    badges_importers_index
    breadcrumb('Import Results')
  end

  def challenges_index
    dashboard
    breadcrumb(objects[:course].challenge_term.pluralize, challenges_path)
  end

  def challenges_edit
    challenges_index
    breadcrumb('Editing ' + objects[:challenge].name)
  end

  def challenges_show
    challenges_index
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
  end

  def challenges_new
    challenges_index
    breadcrumb('New ' + objects[:course].challenge_term)
  end

  def challenge_grades_edit
    challenges_show
    breadcrumb('Editing ' + objects[:challenge_grade].team.name + "'s " +  objects[:challenge_grade].challenge.course.challenge_term + " Grade")
  end

  def challenge_grades_show
    challenges_show
    breadcrumb(objects[:challenge_grade].team.name + "'s " + objects[:course].challenge_term + ' Grade')
  end

  def challenges_challenge_grades_new
    challenges_show
    breadcrumb('New ' + objects[:course].challenge_term + ' Grade for ' + objects[:team].name)
  end

  def challenges_challenge_grades_mass_edit
    challenges_index
    breadcrumb(objects[:challenge].name)
  end

  def courses_index
    dashboard
    breadcrumb('Courses', courses_path)
  end

  def courses_overview
    courses_index
    breadcrumb('Overview')
  end

  def courses_new
    courses_index
    breadcrumb('New Course')
  end

  def courses_edit
    courses_index
    breadcrumb('Course Settings')
  end

  def courses_edit_dashboard_message
    dashboard
    breadcrumb('Edit Dashboard Message')
  end

  def courses_show
    courses_index
    breadcrumb(objects[:course].name)
  end

  def earned_badges_edit
    badges_index
    breadcrumb('Editing Awarded ' + objects[:earned_badge].name)
  end

  def earned_badges_mass_edit
    badges_index
    breadcrumb('Quick Award ' + objects[:badge].name)
  end

  def earned_badges_new
    badges_index
    breadcrumb('Award ' + objects[:badge].name)
  end

  def earned_badges_show
    badges_index
    breadcrumb(objects[:earned_badge].student.name + "'s " + objects[:earned_badge].name + objects[:course].badge_term)
  end

  def groups_index
    dashboard
    breadcrumb(objects[:course].group_term.pluralize, groups_path)
  end

  def groups_show
    dashboard
    breadcrumb(objects[:group].course.group_term.pluralize, groups_path)
    breadcrumb(objects[:group].name + " " + objects[:group].course.group_term)
  end

  def groups_new
    groups_index
    breadcrumb('New ' + objects[:course].group_term)
  end

  def groups_edit
    groups_index
    breadcrumb('Editing ' + objects[:group].name + ' ' + objects[:course].group_term)
  end

  def info_dashboard
  end

  def info_syllabus
  end

  def info_gradebook
    dashboard
    breadcrumb('Gradebook')
  end

  def info_earned_badges
    badges_index
    breadcrumb('Awarded ' + objects[:course].badge_term.pluralize, badges_path)
  end

  def info_multiplier_choices
    dashboard
    breadcrumb(objects[:course].weight_term + ' Choices')
  end

  def info_predictor
    dashboard
    breadcrumb('Predictor Preview', predictor_path)
  end

  def info_grading_status
    dashboard
    breadcrumb('Grading Status', grading_status_path)
  end

  def info_per_assign
    dashboard
    breadcrumb(objects[:assignment_types].first.course.assignment_term + " Analytics")
  end

  def institutions_edit
    institutions_index
    breadcrumb('Edit Institution')
  end

  def institutions_index
    dashboard
    breadcrumb("Institutions", institutions_path)
  end

  def institutions_new
    institutions_index
    breadcrumb('New Institution')
  end

  def integrations_index
    dashboard
    breadcrumb(objects[:course].name, course_path(objects[:course]))
    breadcrumb('Integrations')
  end

  def integrations_courses_index
    courses_index
    breadcrumb('Integrations', integrations_path)
    breadcrumb("#{objects[:provider_name].capitalize} Integration")
  end

  def downloads_index
    dashboard
    breadcrumb('Course Data Exports')
  end

  def events_index
    dashboard
    breadcrumb('Calendar Events', events_path)
  end

  def events_show
    events_index
    breadcrumb(objects[:event].name)
  end

  def events_edit
    events_index
    breadcrumb('Editing ' + objects[:event].name)
  end

  def events_new
    events_index
    breadcrumb('New Event')
  end

  def grade_scheme_elements_index
    dashboard_path
    breadcrumb('Grading Scheme', grade_scheme_elements_path)
  end

  def grade_scheme_elements_mass_edit
    grade_scheme_elements_index
    breadcrumb('Edit Grading Scheme')
  end

  def grade_scheme_elements_edit
    grade_scheme_elements_index
    breadcrumb("Editing #{objects[:grade_scheme_element].name}")
  end

  def grades_show
    assignments_index
    breadcrumb(objects[:grade].assignment.name, assignment_path(objects[:grade].assignment))
    breadcrumb('Showing Grade')
  end

  def grades_edit
    assignments_index
    breadcrumb(objects[:grade].assignment.name, assignment_path(objects[:grade].assignment))
    breadcrumb('Editing Grade')
  end

  def grades_importers_index
    assignments_index
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb('Grade Import', assignment_grades_importers_path(objects[:assignment]))
  end

  def grades_importers_csv
    grades_importers_index
    breadcrumb('CSV')
  end

  def grades_importers_assignments
    grades_importers_index
    breadcrumb(objects[:provider_name].capitalize + ' ' + objects[:course].assignment_term)
  end

  def grades_importers_grades
    grades_importers_index
    breadcrumb(objects[:provider_name].capitalize + ' Grades')
  end

  def grades_importers_grades_import_results
    grades_importers_index
    breadcrumb('Import Results')
  end

  def grades_importers_import_results
    grades_importers_index
    breadcrumb('Import Results')
  end

  def learning_objectives_categories_edit
    learning_objectives_objectives_index
    breadcrumb("Edit #{objects[:category].name}")
  end

  def learning_objectives_categories_new
    learning_objectives_objectives_index
    breadcrumb("Add #{objects[:course].learning_objective_term.pluralize} Category")
  end

  def learning_objectives_objectives_edit
    learning_objectives_objectives_index
    breadcrumb("Edit #{objects[:course].learning_objective_term}")
  end

  def learning_objectives_objectives_index
    dashboard
    breadcrumb(objects[:course].learning_objective_term, learning_objectives_objectives_path)
  end

  def learning_objectives_objectives_new
    learning_objectives_objectives_index
    breadcrumb("Add #{objects[:course].learning_objective_term}")
  end

  def rubrics_index_for_copy
    dashboard
  end

  def rubrics_edit
    assignments_index
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb('Design Rubric')
  end

  def observers_index
    dashboard
    breadcrumb('Observers', observers_path)
  end

  def users_search
    dashboard
    breadcrumb('Search Users', search_users_path)
  end

  def staff_index
    dashboard
    breadcrumb('Staff', staff_index_path)
  end

  def staff_show
    staff_index
    breadcrumb(objects[:staff_member].name)
  end

  def students_index
    dashboard
    breadcrumb(objects[:course].student_term.pluralize, students_path)
  end

  def students_show
    students_index
  end

  def submissions_show
    dashboard
    breadcrumb(objects[:submission].assignment.name, assignment_path(objects[:submission].assignment))
  end

  def submissions_edit
    dashboard
    breadcrumb("Edit " + objects[:assignment].name.titleize + " Submission")
  end

  def submissions_new
    dashboard
    breadcrumb("New Submission")
  end

  def teams_index
    dashboard
    breadcrumb(objects[:course].team_term.pluralize, teams_path)
  end

  def teams_show
    teams_index
    breadcrumb(objects[:team].name)
  end

  def teams_edit
    teams_index
    breadcrumb('Editing ' + objects[:team].name)
  end

  def teams_new
    teams_index
    breadcrumb('New ' + objects[:course].team_term)
  end

  def users_activate
  end

  def user_sessions_new
    dashboard
  end

  def users_edit_profile
    dashboard
    breadcrumb('Edit My GradeCraft Profile')
  end

  def users_import
    users_importers_index
    breadcrumb('Import Users')
  end

  def users_import_results
    students_index
    breadcrumb('Imported ' + objects[:course].student_term.pluralize)
  end

  def users_importers_index
    users_index
    breadcrumb('Users Import', users_importers_path)
  end

  def users_importers_users
    users_importers_index
    breadcrumb("#{objects[:provider_name].capitalize} Users")
  end

  def users_importers_user_import_results
    users_importers_index
    breadcrumb('Import Results')
  end

  def users_index
    dashboard
    breadcrumb('Users', users_path)
  end

  def users_new
    users_index
    breadcrumb('New User')
  end

  def users_edit
    dashboard
    breadcrumb('Editing ' + objects[:user].name)
  end

  def passwords_edit
  end

  def pages_index
  end

  def pages_auth_failure
    dashboard
  end

  def pages_press
  end

  def pages_research
  end

  def pages_team
  end

  def pages_features
  end

  def pages_sign_up
  end
end
