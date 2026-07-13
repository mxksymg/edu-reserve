class ReservationPolicy < ApplicationPolicy
  # Checks whether the user is logged in. Every logged-in user can view their own reservations.
  def index?
    user.present?
  end
  # Checks whether the user is logged in and (is an admin or is the owner of the reservation.
  def show?
    user.present? && (user.admin? || record.user_id == user.id)
  end
  # Checks whether the user is logged. Only students and admins can reserve spots for classes.
  def create?
    user.present? && (user.student? || user.admin?)
  end
  # Checks whether the user is logged in. Student can cancel their own reservation, while an admin can delete any reservation (in case of issues).
  def destroy?
    user.present? && (user.admin? || record.user_id == user.id)
  end
  def confirm?
    # Checks whether the current user is an administrator or a teacher.
    user.admin? || user.teacher?
  end
  def cancel?
    user.admin? || user.teacher? || user.id == record.user_id
  end

  # Scope is a Pundit mechanism that limits the list of records a user is allowed to see.
  class Scope < Scope
    # Returns a list of records.
    def resolve
      if user.admin?
        # Returns ALL reservations. scope.all – the basic query (e.g. Reservation.all).
        scope.all
      elsif user.teacher?
        # scope.joins(schedule: :course) – joins the tables: reservations + schedules + courses.
        # .where(schedules: { teacher_id: user.id }) – filters by the teacher.
        # SELECT * FROM reservations INNER JOIN schedules ON schedules.id = reservations.schedule_id INNER JOIN courses ON
        # courses.id = schedules.course_id WHERE schedules.teacher_id = 5
        scope.joins(schedule: :course).where(schedules: { teacher_id: user.id })
      else
        # If the user is a student, returns only their own reservations.
        scope.where(user_id: user.id)
      end
    end
  end
end
