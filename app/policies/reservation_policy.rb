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
end