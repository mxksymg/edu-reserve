class CoursePolicy < ApplicationPolicy
  # Any authenticated user can view the list of courses.
  def index?
    true
  end
  # Any authenticated user can view the details of a course.
  def show?
    true
  end
  # Only administrators or the school owner can create courses
  def create?
    user.admin? || user.teacher?
  end
  # Only administrators or the school owner can update courses.
  def update?
    user.admin? || record.teacher_id == user.id
  end
  # Only administrators can delete courses.
  def destroy?
    user.admin? || record.teacher_id == user.id
  end
end
