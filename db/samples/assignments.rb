#------------------------------------------------------------------------------#

#                  ASSIGNMENT DEFAULT CONFIGURATION                            #

#------------------------------------------------------------------------------#

# Add all attributes that will be passed on any assignment creation here
# with a default value.  All assignments will use defaults when individual
# attributes aren't supplied.

@assignment_default_config = {
  quotes: {
    assignment_created: "A new assignment for each course has been created",
    grades_created: "Grades were created for the assignment",
    prediction_created: "Predictions were created for the assignment",
    submissions_created: "Submissions were created for the assignment",
    rubric_created: "A Rubric was created for the assignment",
    score_levels_created: "Score levels were created for the assignment"
  },
  assignment_type: :grading,
  attributes: {
    # main attributes:
    name: "Generic Assignment",
    open_at: nil,
    due_at: nil,
    full_points: 5000,
    # additional attributes:
    accepts_attachments: false,
    accepts_links: false,
    accepts_submissions: false,
    accepts_submissions_until: nil,
    resubmissions_allowed: false,
    accepts_text: false,
    description: "Basilisk venom Umbridge swiveling blue eye Levicorpus, nitwit blubber oddment tweak. Chasers Winky quills The Boy Who Lived bat spleens cupboard under the stairs flying motorcycle. Sirius Black Holyhead Harpies, you’ve got dirt on your nose. Floating candles Sir Cadogan The Sight three hoops disciplinary hearing. Grindlewald pig’s tail Sorcerer's Stone biting teacup. Fenrir Grayback horseless carriages ‘zis is a chance many would die for!",
    purpose: "Squashy armchairs dirt on your nose brass scales crush the Sopophorous bean with flat side of silver dagger, releases juice better than cutting. Full moon Whomping Willow three turns should do it lemon drops.",
    grade_scope: "Individual",
    hide_analytics: false,
    release_necessary: false,
    student_logged: false,
    threshold_points: 0,
    visible: true,
    pass_fail: false,
    required: false,
  },
  grades: false,
  # only used if :grades is true:
  grade_attributes: {
    raw_points: -> { qd_curve(5000) },
    instructor_modified: true,
    status: nil,
    feedback: nil,
    excluded_from_course_score: false,
  },
  prediction: false,
  prediction_attributes: {
    predicted_points: -> { 0 }
  },
  assignment_score_levels: false,
  rubric: false,
  student_submissions: true, # adds submissions for students
  unlock_condition: false,
  unlock_attributes: {
    condition: :nil,
    condition_type: nil,
    condition_state: nil
  }
}

#------------------------------------------------------------------------------#

#                        Maths

#------------------------------------------------------------------------------#

# Quick and Dirty bell curve:
#   uses central limit theorum,
#   adding a quarter of the points
#   rounds to nearest 100
# Simulates a bell curve around a "C+"
def qd_curve(full_points, samples=10, capped=true)
  val = (((((1..samples).each_with_object([]) {|v,m| m << rand(full_points)})
     .inject(0){|sum,x| sum + x}) /samples) + (0.25 * full_points)).round(-2)

  if capped
    return val > full_points ? full_points : val
  else
    val
  end
end

#------------------------------------------------------------------------------#

#                        Grading Assignment Type

#------------------------------------------------------------------------------#

@assignments = {}

# Add each assignment below, override default configuration for custom
# attributes

@assignments[:pass_fail_no_grade] = {
  quotes: {
    assignment_created: "You will always pass failure on the way to success. \
– Mickey Rooney"
  },
  assignment_type: :grading,
  attributes: {
    name: "Pass/Fail [No grades]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,
    pass_fail: true,

  }
}

@assignments[:pass_fail_with_grades] = {
  quotes: {
    assignment_created: "Do. Or do not. There is no try. -- Yoda"
  },
  assignment_type: :grading,
  attributes: {
    name: "Pass/Fail [Has grades]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,
    pass_fail: true,

  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:standard_edit_quick_grade_text] = {
  quotes: {
    assignment_created: "Study hard what interests you the most in the most \
undisciplined, irreverent and original manner possible. ― Richard Feynman"
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Quick Grade with Text Box [No grades]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,

  }
}

@assignments[:standard_edit_quick_grade_text_graded] = {
  quotes: {
    assignment_created: "We demand rigidly defined areas of doubt and \
uncertainty! - Douglas Adams"
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Quick Grade with Text Box [Grades]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,

  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:standard_edit] = {
  quotes: {
    assignment_created: "For me, I am driven by two main philosophies: know \
more today about the world than I knew yesterday and lessen the \
suffering of others. You'd be surprised how far that gets you. ―Neil \
deGrasse Tyson"
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Quick Grade with Checkbox [No Grades]",
    open_at: 2.weeks.ago,
    due_at: 2.weeks.ago + 0.05,
  }
}

@assignments[:standard_edit_graded] = {
  quotes: {
    assignment_created: "I hope you're pleased with yourselves. We could all \
have been killed - or worse, expelled. Now if you don't mind, I'm going \
to bed. ― J.K. Rowling"
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Quick Grade with Checkbox [Grades]",
    open_at: 2.weeks.ago,
    due_at: 2.weeks.ago + 0.05,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:assignment_score_levels] = {
  quotes: {
    assignment_created: "What a school thinks about its library is a measure \
of what it feels about education.― Harold Howe",
  },
  assignment_type: :grading,
  attributes: {
    name: "Assignment with Score Levels [No Grades]",
    open_at: 2.weeks.ago,
    due_at: 2.weeks.ago + 0.05,
    full_points: 20000,
  },
  assignment_score_levels: true,
}

@assignments[:assignment_score_levels_graded] = {
  quotes: {
    assignment_created: "Education consists mainly of what we have unlearned. \
― Mark Twain, Notebook",
  },
  assignment_type: :grading,
  attributes: {
    name: "Assignment with Score Levels [Grades]",
    open_at: 2.weeks.ago,
    due_at: 2.weeks.ago + 0.05,
    full_points: 20000,
  },
  assignment_score_levels: true,
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:self_log_boolean_assignment] = {
  quotes: {
    assignment_created: "It's not that I feel that school is a good idea gone \
wrong, but a wrong idea from the word go. It's a nutty notion that we can \
have a place where nothing but learning happens, cut off from the rest of \
life.― John Holt",
  },
  assignment_type: :grading,
  attributes: {
    name: "Single-level Self-Logged Assignment [No Grades]",
    open_at: DateTime.now,
    due_at: DateTime.now + 0.05,
    student_logged: true,
  }
}

@assignments[:self_log_boolean_assignment_graded] = {
  quotes: {
    assignment_created: "School should be the best party in town ― Peter Kline",
  },
  assignment_type: :grading,
  attributes: {
    name: "Single-level Self-Logged Assignment [Grades]",
    open_at: DateTime.now,
    due_at: DateTime.now + 0.05,
    student_logged: true,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:threshold_and_insufficient_grades] = {
  quotes: {
    assignment_created: nil
  },
  assignment_type: :grading,
  attributes: {
    name: "Points Threshold and Insufficent Grades",
    description: "Graded Assignment has a points threshold that no student \
met. Grades have a raw_points of 15000",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,
    full_points: 20000,
    threshold_points: 18000
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded",
    raw_points: -> { 15000 },
  }
}

@assignments[:self_log_score_level_assignment] = {
  quotes: {
    assignment_created: "I didn't give it much thought back then. I just \
wanted to get all the words straight and collect my A. ― Gayle Forman, Just \
One Day",
  },
  assignment_type: :grading,
  attributes: {
    name: "Self-Logged with Score Levels Assignment [No Grades]",
    open_at: DateTime.now,
    due_at: DateTime.now + 0.05,
    full_points: 200000,
    student_logged: true,
  },
  assignment_score_levels: true,
}

@assignments[:standard_edit_release_required] = {
  quotes: {
    assignment_created: "But what are schools for if not to make children \
fall so deeply in love with the world that they really want to learn about \
it? That is the true business of schools. And if they succeed in it, all \
other desirable developments follow of themselves. - Marjorie Spock",
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Release Required [No Grades]",
    open_at: 3.weeks.from_now,
    due_at: 3.weeks.from_now + 0.05,
    release_necessary: true
  }
}

@assignments[:unreleased] = {
  quotes: {
  },
  assignment_type: :grading,
  attributes: {
    name: "Release Required, In Progress Grades",
    open_at: 3.weeks.from_now,
    due_at: 3.weeks.from_now + 0.05,
    release_necessary: true
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:grading_in_progress] = {
  quotes: {
  },
  assignment_type: :grading,
  attributes: {
    name: "In Progress Grades",
    open_at: 3.weeks.from_now,
    due_at: 3.weeks.from_now + 0.05,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "In Progress"
  }
}


@assignments[:rubric_assignment] = {
  quotes: {
    assignment_created: "We spend the first year of a child's life teaching \
it to walk and talk and the rest of its life to shut up and sit down. \
There's something wrong there. ― Neil deGrasse Tyson",
    rubric_created: "What is this? A center for ants? How can we be expected \
to teach children to learn how to read... if they can't even fit inside the \
building? --Derek Zoolander",
    submissions_created: "I was the intellectual equivalent of a 98-pound \
weakling! I would go to the beach and people would kick copies of Byron in my \
face! - John Keating"
  },
  assignment_type: :grading,
  attributes: {
    name: "Rubric Graded Assignment [No Grades]",
    open_at: 4.weeks.ago,
    due_at: 3.weeks.ago,
    full_points: 400000,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
    release_necessary: true,
  },
  rubric: true,
  student_submissions: true
}

@assignments[:rubric_assignment_with_threshold] = {
  quotes: {
  },
  assignment_type: :grading,
  attributes: {
    name: "Rubric Graded Assignment With Threshold [No Grades]",
    open_at: 4.weeks.ago,
    due_at: 3.weeks.ago,
    full_points: 400000,
    threshold_points: 200000
  },
  rubric: true
}

@assignments[:rubric_assignment_graded] = {
  quotes: {
    assignment_created: "We spend the first year of a child's life teaching \
it to walk and talk and the rest of its life to shut up and sit down. \
There's something wrong there. ― Neil deGrasse Tyson",
    rubric_created: "What is this? A center for ants? How can we be expected \
to teach children to learn how to read... if they can't even fit inside the \
building? --Derek Zoolander",
    submissions_created: "I was the intellectual equivalent of a 98-pound \
weakling! I would go to the beach and people would kick copies of Byron in \
my face! - John Keating",
    grade_created: "Volumetric flask is for general mixing and titration. \
You wouldn't apply heat to a volumetric flask. That's what a boiling flask \
is for. Did you learn nothing from my chemistry class? - Walter H. White",
  },
  assignment_type: :grading,
  attributes: {
    name: "Rubric Graded Assignment [Grades]",
    open_at: 4.weeks.ago,
    due_at: 3.weeks.ago,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
    release_necessary: true,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Released",
    feedback: 'As Aristotle said, <strong>"The whole is greater than the sum of its parts."</strong>',
  },
  rubric: true,
  student_submissions: true
}

#------------------------------------------------------------------------------#

#                        Group Assignment Type

#------------------------------------------------------------------------------#

@assignments[:group_grade_assignment] = {
  quotes: {
    assignment_created: "I'm sorry, if you were right, I'd agree with you. - \
Robin Williams",
  },
  assignment_type: :group_grading,
  assign_groups: true,
  attributes: {
    name: "Standard Edit Group Assignment",
    full_points: 10000,
    grade_scope: "Group",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
  }
}

@assignments[:group_score_levels] = {
  quotes: {
    assignment_created: "You can't tell if a machine has gotten smarter or if you've just lowered your own standards of intelligence to such a degree that the machine seems smart. ― Jaron Lanier"
  },
  assignment_type: :group_grading,
  assign_groups: true,
  attributes: {
    name: "Score Levels Group Assignment",
    grade_scope: "Group",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
  },
  assignment_score_levels: true
}

@assignments[:group_pass_fail] = {
  quotes: {
    assignment_created: "Numbers have an important story to tell. They rely on you to give them a voice. – Stephen Few"
  },
  assignment_type: :group_grading,
  assign_groups: true,
  attributes: {
    name: "Pass/Fail Group Assignment",
    pass_fail: true,
    grade_scope: "Group",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
  }
}

@assignments[:group_grade_submissions_assignment] = {
  quotes: {
    assignment_created: "Many highly talented, brilliant, creative people \
think they're not - because the thing they were good at at school wasn't \
valued, or was actually stigmatized. - Sir Ken Robinson",
  },
  assignment_type: :group_grading,
  assign_groups: true,
  attributes: {
    name: "Submissions Group Assignment",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
    full_points: 15000,
    grade_scope: "Group",
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  }
}

@assignments[:group_grade_rubric_assignment] = {
  quotes: {
    assignment_created: "It does not matter how slowly you go as long as you \
do not stop.― Confucius",
    rubric_created: "They learn to unlearn, To redeem the fault of the \
people, To assist the nature of all things, Without daring to meddle. - Lao \
Tzu"
  },
  assignment_type: :group_grading,
  assign_groups: true,
  attributes: {
    name: "Rubric Graded Group Assignment",
    full_points: 15000,
    grade_scope: "Group",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
  },
  rubric: true
}

@assignments[:group_grade_assignment_no_groups_assigned] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :group_grading,
  assign_groups: false,
  attributes: {
    name: "No Groups Assigned, Group Assignment",
    full_points: 10000,
    grade_scope: "Group",
    open_at: 1.weeks.ago,
    due_at: 3.weeks.from_now,
  }
}

#------------------------------------------------------------------------------#

#                        Submission Assignment Type

#------------------------------------------------------------------------------#

@assignments[:no_submissions_assignment] = {
  quotes: {
    assignment_created: "The answer is not to standardize education, but to \
personalize and customize it to the needs of each child and community. There \
is no alternative. There never was. –Ken Robinson",
  },
  assignment_type: :submissions,
  attributes: {
    name: "Does Not Accept Submissions",
    open_at: 2.weeks.ago,
    due_at: DateTime.now + 0.05,
    full_points: 200000,
    accepts_submissions: false,
  }
}

@assignments[:accepts_submissions_assignment] = {
  quotes: {
    assignment_created: "One recipe for one kind of fun: 1) Identify the \
inherent learnable challenge, 2) Restructure it optimally with clear goals, \
rules, and feedback, 3) Playtest and iterate –Sebastian Deterding",
  },
  assignment_type: :submissions,
  attributes: {
    name: "Accepts All Types of Submissions",
    due_at: DateTime.now + 0.25,
    full_points: 200000,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  }
}

@assignments[:accepts_resubmissions_assignment] = {
  quotes: {
  },
  assignment_type: :submissions,
  attributes: {
    name: "Accepts Resubmissions of All Types",
    due_at: DateTime.now + 0.25,
    full_points: 200000,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  }
}

@assignments[:accepts_link_submissions_assignment] = {
  quotes: {
    assignment_created: "Good design is a lot like clear thinking made visual. \
–Edward Tufte",
  },
  assignment_type: :submissions,
  attributes: {
    name: "Accepts Link Submissions",
    due_at: DateTime.now + 0.25,
    full_points: 15000,
    accepts_links: true,
    accepts_submissions: true,
  }
}

@assignments[:accepts_attachment_submissions_assignment] = {
  quotes: {
    assignment_created: "Design is where science and art break even. \
–Robin Mathew",
  },
  assignment_type: :submissions,
  attributes: {
    name: "Accepts Attachment Submissions",
    due_at: DateTime.now + 0.25,
    full_points: 15000,
    accepts_attachments: true,
    accepts_links: false,
    accepts_submissions: true,
    accepts_text: false,
  }
}

@assignments[:accepts_text_submissions_assignment] = {
  quotes: {
    assignment_created: "I think constraints are very important. They're \
positive, because they allow you to work off something.–Charles Gwathmey",
  },
  assignment_type: :submissions,
  attributes: {
    name: "Accepts Text Submissions",
    due_at: DateTime.now + 0.25,
    full_points: 15000,
    accepts_attachments: false,
    accepts_links: false,
    accepts_submissions: true,
    accepts_text: true,
  }
}

@assignments[:submission_assignment_submission_open] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Not Submitted, On Time",
    description: "Displays 'Accepts Submissions' icon. Still accepts \
predictions.",
    due_at: 3.week.from_now,
    accepts_submissions_until: 3.week.from_now,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  }
}

@assignments[:submission_past_assignment_submission_open] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Not Submitted, Late",
    description: "Displays 'Accepts Submissions' and 'Late' icons. Still \
accepts predictions.",
    due_at: 1.week.ago,
    accepts_submissions_until: 3.week.from_now,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  }
}

@assignments[:submission_past_assignment_submission_closed] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Not Submitted, Closed",
    description: "Fixed at 0 points, displays 'Closed' and 'Late' icons. Has prediction which should not be added to point calculations. Should be closed in predictor",
    due_at: 1.week.ago,
    accepts_submissions_until: 1.week.ago,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:submission_past_assignment_with_submissions] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Has Submission, Closed",
    description: "Displays 'Has Submission' icon. Has slider, accepts prediction.",
    due_at: 1.week.ago,
    accepts_submissions_until: 1.week.ago,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  },
  student_submissions: true
}

@assignments[:submission_open_assignment_with_submissions] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Has Submission, Open",
    description: "Displays 'Has Submission' icons, has slider, accepts
      prediction.",
    due_at: 5.weeks.from_now,
    accepts_submissions_until: 5.weeks.from_now,
    accepts_submissions: true,
    resubmissions_allowed: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
  },
  student_submissions: true
}

@assignments[:submission_has_grade_no_submission] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :submissions,
  attributes: {
    name: "Close without Submission, Has Grade",
    description: "Displays 'No Submission' icons, displays as graded in predictor.",
    due_at: 1.week.ago,
    accepts_submissions_until: 1.week.ago,
    accepts_submissions: false,
    resubmissions_allowed: false,
    accepts_attachments: false,
    accepts_text: false,
    accepts_links: false,
  },
  student_submissions: false,
  grades: true,
  participation: 100,
  grade_attributes: {
    status: "Graded"
  }
}


#------------------------------------------------------------------------------#

#                        Predictor Assignment Type

#------------------------------------------------------------------------------#

@assignments[:predictor_with_graded_grade_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Past Assignment with Grade",
    description: "Points displayed and info icon",
    due_at: 1.week.ago,
    full_points: 15000,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_with_excluded_grade_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Excluded Grade Assignment",
    description: "Points displayed with exclusion message and stying, points \
not added to total",
    due_at: 1.week.ago,
    full_points: 15000,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded",
    excluded_from_course_score: true
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_past_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Past Assignment no Grade",
    description: "Displays a Slider. Displays the info icon with this text \
on hover",
    due_at: 1.week.ago,
    full_points: 15000,
  }
}

@assignments[:predictor_past_assignment_with_prediction] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Past Assignment no Grade but Prediction",
    description: "Has prediction which should not be added to point calculations. Should be closed at 0 points in the Predictor. displays 'Closed' and 'Late' icons.",
    due_at: 1.week.ago,
    accepts_submissions: true,
    accepts_submissions_until: 1.week.ago,
    full_points: 15000,
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_past_with_unreleased_grade_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Past Assignment Unreleased Grade",
    description: "Should have a prediction slider, should have a prediction, \
should not have a visible grade",
    due_at: 1.week.ago,
    full_points: 15000,
    release_necessary: true,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    raw_points: -> { qd_curve(15000) },
    status: "Released"
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_fixed_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Fixed no Prediction",
    description: "Should have a binary predictor switch with zero prediction",
    due_at: 1.week.from_now,
    full_points: 15000,
  }
}

@assignments[:predictor_fixed_assignment_predicted] = {
  quotes: {
    assignment_created: "The whole educational and professional training \
system is a very elaborate filter, which just weeds out people who are too \
independent, and who think for themselves, and who don't know how to be \
submissive, and so on -- because they're dysfunctional to the institutions. \
― Noam Chomsky",
  },
  assignment_type: :predictor,
  attributes: {
    name: "Fixed with Prediction",
    description: "Should have a binary predictor switch with zero prediction",
    due_at: 1.week.from_now,
    full_points: 15000,
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_fixed_assignment_graded_predicted] = {
  quotes: {
    assignment_created: "The whole educational and professional training \
system is a very elaborate filter, which just weeds out people who are too \
independent, and who think for themselves, and who don't know how to be \
submissive, and so on -- because they're dysfunctional to the institutions. \
― Noam Chomsky",
  },
  assignment_type: :predictor,
  attributes: {
    name: "Graded Fixed Assignment",
    description: "Should have full points",
    due_at: 1.week.from_now,
    full_points: 15000,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    raw_points: -> { 15000 },
    status: "Graded"
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_continuous_slider_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Slider No Prediction",
    description: "Should have a continuous slider with zero prediction",
    due_at: 1.week.from_now,
    full_points: 15000,
  }
}

@assignments[:predictor_continuous_slider_assignment_predicted] = {
  quotes: {
    assignment_created: "We are students of words: we are shut up in schools, \
and colleges, and recitation -rooms, for ten or fifteen years, and come out \
at last with a bag of wind, a memory of words, and do not know a thing. ― \
Ralph Waldo Emerson",
  },
  assignment_type: :predictor,
  attributes: {
    name: "Slider with Prediction",
    description: "Should have a continuous slider with random prediction",
    due_at: 1.week.from_now,
    full_points: 15000,
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

@assignments[:predictor_slider_with_levels_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Score Level Slider no Prediction",
    description: "Should have a slider with levels with zero prediction",
    due_at: 1.week.from_now,
    full_points: 25000,
  },
  assignment_score_levels: true
}

@assignments[:predictor_slider_with_levels_assignment_graded] = {
  quotes: {
    assignment_created: "What's gotten in the way of education in the United \
States is a theory of social engineering that says there is ONE RIGHT WAY \
to proceed with growing up. ― John Taylor Gatto",
  },
  assignment_type: :predictor,
  attributes: {
    name: "Score Level Slider with Prediction",
    description: "Should have a slider with levels with random prediction",
    due_at: 1.week.from_now,
    full_points: 25000,
  },
  assignment_score_levels: true,
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { 25000 }
  }
}

@assignments[:predictor_slider_with_thresholds_and_levels] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Score Level Slider and Threshold",
    description:
      "Should have a slider with both Level and a Threshold Behavior",
    due_at: 1.week.from_now,
    full_points: 25000,
    threshold_points: 15000,
  },
  assignment_score_levels: true,
}

@assignments[:predictor_assignment_with_icons] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :predictor,
  attributes: {
    name: "Assignment With Icons and Score Levels",
    description:
      "Should have a required, late, and locked icon in main widget, and score levels",
    due_at: 2.weeks.ago + 0.05,
    accepts_submissions: true,
    required: true
  },
  assignment_score_levels: true,
  unlock_condition: true,
  unlock_attributes: {
    condition: :badge_unlock_assignment_condition,
    condition_type: "Badge",
    condition_state: "Earned"
  }
}

#------------------------------------------------------------------------------#

#                        Visibility Assignment Type

#------------------------------------------------------------------------------#

@assignments[:invisible_assignment] = {
  quotes: {
    assignment_created: "Invisible Learning is a recognition that most of the \
learning we do is “invisible” – that is, it is through informal, non-formal, \
and serendipitous experiences rather than through formal instruction. --  \
John Moravec",
  },
  assignment_type: :visibility,
  attributes: {
    name: "I'm an Invisible Assignment",
    due_at: 2.weeks.from_now,
    full_points: 15000,
    visible: false,
  }
}

@assignments[:visible_assignment] = {
  quotes: {
    assignment_created: "College: two hundred people reading the same book. An \
obvious mistake. Two hundred people can read two hundred books. ― John Cage",
  },
  assignment_type: :visibility,
  attributes: {
    name: "Hey, I'm a Visible Assignment!",
    due_at: 2.weeks.from_now,
    full_points: 15000,
    visible: true,
  }
}

@assignments[:sends_email_notes_on_release] = {
  quotes: {
    assignment_created: "People tend to forget that play is serious. – David \
Hockney",
  },
  assignment_type: :notifications,
  attributes: {
    name: "Grade Triggers Email",
    description: "I send out emails when student receives a grade",
    due_at: 4.weeks.from_now,
    full_points: 150000,
    release_necessary: true,
  }
}

@assignments[:analytics_on] = {
  quotes: {
    assignment_created: "The saddest aspect of life right now is that science \
gathers knowledge faster than society gathers wisdom. ― Isaac Asimov",
  },
  assignment_type: :analytics,
  attributes: {
    name: "Indvidual Assignment + Analytics",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    hide_analytics: false,
  }
}

@assignments[:groups_analytics_on] = {
  quotes: {
    assignment_created: "Of all sad words of tongue or pen, the saddest are \
these, 'It might have been.' ― John Greenleaf Whittier",
  },
  assignment_type: :analytics,
  assign_groups: true,
  attributes: {
    name: "Group Assignment + Analytics",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    hide_analytics: false,
    grade_scope: "Group",
  }
}

@assignments[:hidden_analytics_on] = {
  quotes: {
    assignment_created: "People aren't either wicked or noble. They're like \
chef's salads, with good things and bad things chopped and mixed together in \
a vinaigrette of confusion and conflict. ― Lemony Snicket",
  },
  assignment_type: :analytics,
  attributes: {
    name: "Indvidual Assignment + Hidden Analytics",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    hide_analytics: true,
  }
}

@assignments[:groups_hidden_analytics_on] = {
  quotes: {
    assignment_created: "Life can only be understood backwards; but it must \
be lived forwards. ― Soren Kierkegaard",
  },
  assignment_type: :analytics,
  assign_groups: true,
  attributes: {
    name: "Group Assignment + Hidden Analytics",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    hide_analytics: true,
    grade_scope: "Group",
  }
}

#------------------------------------------------------------------------------#

#                        Unlock Assignment Type

#------------------------------------------------------------------------------#

@assignments[:badge_is_an_unlock] = {
  quotes: {
    assignment_created: "Badges, to g**-d***** h*** with badges! We have no \
badges. In fact, we don’t need badges. I don't have to show you any \
stinking badges, you g**-d***** cabron and c****’ tu madre! – B. Traven",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Badge-Example",
    description: "Earning the Badge Assignment-Unlock-Key unlocks this \
assignment.",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :badge_unlock_assignment_condition,
    condition_type: "Badge",
    condition_state: "Earned"
  }
}

@assignments[:unlock_submission_condition] = {
  quotes: {
    assignment_created: "Now, it is the view of the Ministry that a \
theoretical knowledge will be more than sufficient to get you through your \
examination, which, after all, is what school is all about.―J.K. Rowling",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Submission-Key",
    description:
      "I'm the thing you need to submit to unlock 'Unlocked-By-Submission'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
  }
}

@assignments[:submission_is_an_unlock] = {
  quotes: {
    assignment_created: "School has become the world religion of a modernized \
proletariat, and makes futile promises of salvation to the poor of the \
technological age. ― Ivan Illich",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Submission",
    description: "Submitting 'Submission-Key' unlocks this assignment",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :unlock_submission_condition,
    condition_type: "Assignment",
    condition_state: "Submitted"
  }
}

@assignments[:unlock_grade_earned_condition] = {
  quotes: {
    assignment_created: "In all the works on pedagogy that ever I read — and \
they have been many, big, and heavy — I don't remember that any one has \
advocated a system of teaching by practical jokes, mostly cruel. That, \
however, describes the method of our great teacher, Experience. ― Charles \
Sanders Peirce",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlock-Grade-Earned-Key",
    description: "I'm the thing you need to earn a grade on to unlock
      'Unlocked-By-Grade-Earned'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  }
}

@assignments[:grade_earned_is_an_unlock] = {
  quotes: {
    assignment_created: "The public has a distorted view of science because \
children are taught in school that science is a collection of firmly \
established truths. In fact, science is not a collection of truths. It is \
a continuing exploration of mysteries. ― Freeman Dyson",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Grade-Earned",
    description:
      "Earning a Grade for 'Unlock-Grade-Earned-Key' unlocks this one",
    due_at: 2.weeks.ago + 0.05,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :unlock_grade_earned_condition,
    condition_type: "Assignment",
    condition_state: "Grade Earned"
  }
}

@assignments[:unlock_grade_earned_by_date_condition] = {
  quotes: {
    assignment_created: "The 'polymath' had already died out by the close of \
the eighteenth century, and in the following century intensive education \
replaced extensive, so that by the end of it the specialist had evolved. \
The consequence is that today everyone is a mere technician, even the artist...\
― Dietrich Bonhoeffer",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlock-Grade-Earned-By-Date-Key",
    description: "I'm the thing you need to earn a grade on by a date to unlock
      'Unlocked-By-Grade-Earned-By-Date'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  }
}

@assignments[:grade_earned_by_date_is_an_unlock] = {
  quotes: {
    assignment_created: "Placing the burden on the individual to break down \
doors in finding better education for a child is attractive to conservatives \
because it reaffirms their faith in individual ambition and autonomy. But to \
ask an individual to break down doors that we have chained and bolted in \
advance of his arrival is unfair. ― Jonathan Kozol",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Grade-Earned-By-Date",
    description:
      "Earning a Grade for 'Unlock-Grade-Earned-By-Date-Key' unlocks this",
    due_at: 2.weeks.ago + 0.05,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :unlock_grade_earned_by_date_condition,
    condition_type: "Assignment",
    condition_state: "Grade Earned",
    condition_date: 1.week.ago
  }
}

@assignments[:unlock_feedback_read_condition] = {
  quotes: {
    assignment_created: "Generally in life, knowledge is acquired to be used. \
But school learning more often fits Freire's apt metaphor: knowledge is \
treated like money, to be put away in a bank for the future. ― Seymour Papert",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlock-Feedback-Read-Key",
    description: "I'm the thing you need to read the feedback on to unlock
      'Unlocked-By-Feedback-Read'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded",
    raw_points: -> { 180000 },
    feedback: 'As George Washington Carver said, <strong>"Education is the key
      to unlock the golden door of freedom."</strong>'
  }
}

@assignments[:feedback_read_is_an_unlock] = {
  quotes: {
    assignment_created: "To explain something to someone is first of all to \
show him he cannot understand it by himself. ― Jacques Rancière",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Feedback-Read",
    description: "Reading the Feedback on 'Unlock-Feedback-Read-Key' unlocks
      this",
    due_at: 2.weeks.ago + 0.05,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :unlock_feedback_read_condition,
    condition_type: "Assignment",
    condition_state: "Feedback Read",
  }
}

@assignments[:unlock_feedback_read_by_date_condition] = {
  quotes: {
    assignment_created: "Grandma calls it the Socratic Method. She considers \
it the highest pedagogical technique. I call it cornering a person. Instead \
of just telling you what I want you to know, I ambush you with questions. \
You try to escape, but you can’t. You can run whichever way you like, but \
in the end you’ll fall right into my trap. ― Sophia Nikolaidou",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlock-Feedback-Read-By-Date-Key",
    description: "I'm the thing you need to read the feedback on by a date to
      unlock 'Unlocked-By-Feedback-Read-By-Date'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded",
    raw_points: -> { 180000 },
    feedback: 'As Winston Churchill said, <strong>"Continuous effort - not
      strength or intelligence - is the key to unlocking our potential.
      "</strong>'
  }
}

@assignments[:feedback_read_by_date_is_an_unlock] = {
  quotes: {
    assignment_created: "School people must not fall into the trap of \
thinking that early preparation for an unjust world requires early exposure \
to injustice ― Oakes Jeannie",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Feedback-Read-By-Date",
    description: "Reading the Feedback on 'Unlock-Feedback-Read-By-Date-Key'
      Unlocks this",
    due_at: 4.weeks.from_now,
    full_points: 180000,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :unlock_feedback_read_by_date_condition,
    condition_type: "Assignment",
    condition_state: "Feedback Read",
    condition_date: 1.week.ago
  }
}

@assignments[:group_unlock_submission_condition] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Group-Submission-Key",
    description: "I'm the thing you need to submit to unlock
      'Group-Assignment-Unlocked-By-Submission'",
    due_at: 4.weeks.from_now,
    full_points: 180000,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
  }
}

@assignments[:group_assignment_submission_is_an_unlock] = {
  quotes: {
    assignment_created: "My contention is that creativity now is as important \
in education as literacy, and we should treat it with the same status. – \
Sir Ken Robinson",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Group-Assignment-Unlocked-By-Submission",
    description: "All members of a Group Submitting 'Group-Submission-Key'
      unlocks this assignment",
    due_at: 3.weeks.from_now,
    full_points: 180000,
    grade_scope: "Group",
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
  },
  assign_groups: true,
  unlock_condition: true,
  unlock_attributes: {
    condition: :group_unlock_submission_condition,
    condition_type: "Assignment",
    condition_state: "Submitted"
  }
}

@assignments[:group_assignment_submission_is_a_condition] = {
  quotes: {
    assignment_created: "The difference between school and life? In school, \
you're taught a lesson and then given a test. In life, you're given a test \
that teaches you a lesson. – Tom Bodett",
  },
  assignment_type: :unlocks,
  assign_groups: true,
  attributes: {
    name: "Group-Assignment-Submission-Unlocks ",
    description: "All members of a Group Submitting 'Submission-Key' unlocks
      this assignment",
    due_at: 5.weeks.from_now,
    full_points: 120000,
    grade_scope: "Group",
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_links: true,
    accepts_text: true,
  }
}

@assignments[:indiv_assignment_submission_is_unlocked_by_group_submission] = {
  quotes: {
    assignment_created: "The difference between school and life? In school, \
you're taught a lesson and then given a test. In life, you're given a \
test that teaches you a lesson. – Tom Bodett",
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Individual-Assignment-Unlocked-By-Group ",
    description: "All members of a Group Submitting 'Submission-Key' unlocks
      this assignment",
    due_at: 5.weeks.from_now,
    full_points: 120000
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :group_assignment_submission_is_a_condition,
    condition_type: "Assignment",
    condition_state: "Submitted"
  }
}

@assignments[:passed_unlock_submission_condition] = {
  quotes: {
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Past-Submission-Key",
    description:
      "It's too late, but I was the thing you needed to submit to unlock 'Unlocked-By-Past-Submission' Should be closed in Predictor",
    due_at: 4.weeks.ago,
    full_points: 180000,
    accepts_submissions: true,
    accepts_submissions_until: 1.week.ago,
  }
}

@assignments[:past_submission_is_an_unlock] = {
  quotes: {
  },
  assignment_type: :unlocks,
  attributes: {
    name: "Unlocked-By-Past-Submission",
    description: "Submitting 'Submission-Key' would have unlocked this assignment, now I am closed in the predictor, and my prediction should not be added to the Assignment Type total",
    full_points: 180000,
  },
  unlock_condition: true,
  unlock_attributes: {
    condition: :passed_unlock_submission_condition,
    condition_type: "Assignment",
    condition_state: "Submitted"
  },
  prediction: true,
  prediction_attributes: {
    predicted_points: -> { qd_curve(15000) }
  }
}

#------------------------------------------------------------------------------#

#                        Sorting Assignment Type

#------------------------------------------------------------------------------#

@assignments[:alphanum_1_condition] = {
  quotes: {
    assignment_created: "In a classical joke a child stays behind after school \
to ask a personal question. 'Teacher, what did I learn today?' The surprised \
teacher asks, 'Why do you ask that?' and the child replies, 'Daddy always asks \
me and I never know what to say.' ― Seymour Papert",
  },
  assignment_type: :sorting,
  attributes: {
    name: "Class 1 Position 1",
    description: "Tests that Assignments are Sorted Correctly by Alphanumeric
      Name as well as by Position (most views use should use Position)"
  }
}

@assignments[:alphanum_2_condition] = {
  quotes: {
    assignment_created: "Nothing bothers me more than when people criticize my \
criticism of school by telling me that schools are not just places to learn \
maths and spelling, they are places where children learn a vaguely defined \
thing called socialization. I know. I think schools generally do an effective \
and terribly damaging job of teaching children to be infantile, dependent, \
intellectually dishonest, passive and disrespectful to their own developmental \
capacities. - Seymour Papert",
  },
  assignment_type: :sorting,
  attributes: {
    name: "Class 2 Position 2",
    description: "Tests that Assignments are Sorted Correctly by Alphanumeric
      Name as well as by Position (most views use should use Position)"
  }
}

@assignments[:alphanum_12_condition] = {
  quotes: {
    assignment_created: "School is the advertising agency which makes you \
believe that you need the society as it is. ― Ivan Illich",
  },
  assignment_type: :sorting,
  attributes: {
    name: "Class 12 Position 3",
    description: "Tests that Assignments are Sorted Correctly by Alphanumeric
      Name as well as by Position (most views use should use Position)"
  }
}

@assignments[:alphanum_10_condition] = {
  quotes: {
    assignment_created: "Most learning is not the result of instruction. It is \
rather the result of unhampered participation in a meaningful setting. Most \
people learn best by being 'with it,' yet school makes them identify their \
personal, cognitive growth with elaborate planning and manipulation. ― Ivan \
Illich",
  },
  assignment_type: :sorting,
  attributes: {
    name: "Class 10 Position 4",
    description: "Tests that Assignments are Sorted Correctly by Alphanumeric
      Name as well as by Position (most views use should use Position)"
  }
}

@assignments[:alphanum_20_condition] = {
  quotes: {
    assignment_created: "Formal learning is like riding a bus: the driver \
decides where the bus is going; the passengers are along for the ride. \
Informal learning is like riding a bike: the rider chooses the destination, \
the speed, and the route.― Jay Cross",
  },
  assignment_type: :sorting,
  attributes: {
    name: "Class 20 Position 5",
    description: "Tests that Assignments are Sorted Correctly by Alphanumeric
      Name as well as by Position (most views use should use Position)"
  }
}

#------------------------------------------------------------------------------#

#                        Weighting Assignment Types

#------------------------------------------------------------------------------#

@assignments[:weighting_one_sample_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_one,
  attributes: {
    name: "Weighted Assignment Type 1",
    full_points: 50000,
    due_at: 4.weeks.from_now,
  }
}

@assignments[:weighting_one_sample_graded_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_one,
  attributes: {
    name: "Weighted and Graded Type 1",
    point_total: 50000,
    due_at: 4.weeks.from_now,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:weighting_two_sample_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_two,
  attributes: {
    name: "Weighted Assignment Type 2",
    full_points: 50000,
    due_at: 4.weeks.from_now,
  }
}

@assignments[:weighting_two_sample_graded_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_two,
  attributes: {
    name: "Weighted and Graded Type 2",
    point_total: 50000,
    due_at: 4.weeks.from_now,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:weighting_three_sample_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_three,
  attributes: {
    name: "Weighted Assignment Type 3",
    full_points: 50000,
    due_at: 4.weeks.from_now,
  }
}

@assignments[:weighting_three_sample_graded_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_three,
  attributes: {
    name: "Weighted and Graded Type 3",
    point_total: 50000,
    due_at: 4.weeks.from_now,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:weighting_four_sample_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_four,
  attributes: {
    name: "Weighted Assignment Type 4",
    full_points: 50000,
    due_at: 4.weeks.from_now,
  }
}

@assignments[:weighting_four_sample_graded_assignment] = {
  quotes: {
    assignment_created: nil,
  },
  assignment_type: :weighting_four,
  attributes: {
    name: "Weighted and Graded Type 4",
    point_total: 50000,
    due_at: 4.weeks.from_now,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Graded"
  }
}

@assignments[:pass_fail_with_grades_and_allows_resubmissions] = {
  quotes: {
    assignment_created: "Do. Or do not. There is no try. -- Yoda"
  },
  assignment_type: :grading,
  attributes: {
    name: "Pass/Fail [Has grades with submissions and allows resubmissions]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,
    pass_fail: true,
    resubmissions_allowed: true,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
    release_necessary: true,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Released"
  }
}

@assignments[:standard_edit_quick_grade_text_graded_and_allows_resubmissions] = {
  quotes: {
    assignment_created: "We demand rigidly defined areas of doubt and \
uncertainty! - Douglas Adams"
  },
  assignment_type: :grading,
  attributes: {
    name: "Standard Edit + Quick Grade with Text Box [Grades and allows resubmissions]",
    open_at: 1.weeks.from_now,
    due_at: 1.weeks.from_now + 0.05,
    resubmissions_allowed: true,
    accepts_submissions: true,
    accepts_attachments: true,
    accepts_text: true,
    accepts_links: true,
    release_necessary: true,
  },
  grades: true,
  participation: 90,
  grade_attributes: {
    status: "Released"
  }
}
