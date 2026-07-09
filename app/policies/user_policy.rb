class UserPolicy < ApplicationPolicy
  def index?
    # Only admin and teacher can view the list of users
    user.admin? || user.teacher?
  end
  def show?
    user.admin? || user.teacher? || user.id == record.id
  end
  def update?
    user.admin? || user.id == record.id
  end
  def update_role?
    user.admin?
  end
  def destroy?
    user.admin?
  end
  class Scope < ApplicationPolicy::Scope
    # Returns the list of users that the person is allowed to see.
    def resolve
      if user.admin?
        # Returns ALL users. scope.all – the basic query (e.g. User.all).
        scope.all
      # If the user is a teacher.
      elsif user.teacher?
        # Returns only students.
        scope.where(role: "student")
      # If the user is a student (or another role).
      else
        # Returns only themselves. scope.where(id: user.id) – filters by ID.
        scope.where(id: user.id)
      end
    end
  end
end
