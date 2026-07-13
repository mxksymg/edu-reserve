class CalendarPolicy < ApplicationPolicy
  # Only administrators or the teacher
  def index?
    user.teacher? || user.admin?
  end

  # Only administrators or the teacher
  def show?
    user.teacher? || user.admin?
  end

  # Only administrators or the teacher
  def edit?
    user.teacher? || user.admin?
  end

  # Only administrators or the teacher
  def update?
    user.teacher? || user.admin?
  end

  # Only admin
  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        # Admin sees all schedules
        scope.all
      elsif user.teacher?
        # Techer sees his own schedules
        scope.where(teacher_id: user.id)
      else
        scope.none
      end
    end
  end
end
