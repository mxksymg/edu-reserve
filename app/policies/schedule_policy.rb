class SchedulePolicy < ApplicationPolicy
  # Any authenticated user can view the list of schedules.
  def index?
    true
  end
  # Any authenticated user can view the details of a schedule.
  def show?
    true
  end
  # Only administrators or the school owner can create schedules.
  def create?
    user.admin? || user.school_owner?
  end
  # Only administrators or the school owner can update schedules.
  def update?
    user.admin? || user.school_owner?
  end
  # Only administrators can delete schedules.
  def destroy?
    user.admin?
  end
end
