class SchoolPolicy < ApplicationPolicy
  # Any logged in user can view the list of schools.
  def index?
    true
  end
  # Any logged in user can view the details of school.
  def show?
    true
  end
  # Only admin can create new school.
  def create?
    user.admin?
  end
  # Admin and school owner can edit school.
  def update?
    user.admin? || record.user_id == user.id
  end
  # Only admin can delete a school
  def destory?
    user.admin?
  end
end
