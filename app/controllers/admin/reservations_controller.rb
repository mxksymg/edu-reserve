class Admin::ReservationsController < WebApplicationController
  layout "application"
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_reservation, only: [ :show, :destroy, :confirm, :cancel ]

  def index
    # SELECT "reservations".* FROM "reservations" ORDER BY "reservations"."created_at" DESC
    # SELECT "users".* FROM "users" WHERE "users"."id" IN (1, 2, 3, 4, 5)
    # SELECT "schedules".* FROM "schedules" WHERE "schedules"."id" IN (1, 2, 3, 4, 5)
    # SELECT "courses".* FROM "courses" WHERE "courses"."id" IN (1, 2, 3)
    @reservations = Reservation.includes(:user, schedule: :course).order(created_at: :desc)

    # Filtrowanie po statusie
    if params[:status].present?
        # SELECT "reservations".* FROM "reservations" WHERE "reservations"."status" = 'pending'ORDER BY "reservations"."created_at" DESC
        @reservations = @reservations.where(status: params[:status])
    end

    # Filtrowanie po kursie
    if params[:course_id].present?
        # SELECT "reservations".* FROM "reservations" INNER JOIN "schedules" ON "schedules"."id" = "reservations"."schedule_id"
        # INNER JOIN "courses" ON "courses"."id" = "schedules"."course_id" WHERE "courses"."id" = 2 ORDER BY "reservations"."created_at" DESC
        @reservations = @reservations.joins(schedule: :course).where(courses: { id: params[:course_id] })
    end

    # Filtrowanie po użytkowniku
    if params[:user_email].present?
        @reservations = @reservations.joins(:user).where("users.email ILIKE ?", "%#{params[:user_email]}%")
    end
    # SELECT "reservations".* FROM "reservations" ORDER BY "reservations"."created_at" DESC LIMIT 20 OFFSET 0
    @reservations = @reservations.paginate(page: params[:page], per_page: 20)
  end

  def show
  end

  def destroy
    if @reservation.destroy
        redirect_to admin_reservations_path, notice: "✅ Rezerwacja została usunięta!"
    else
        redirect_to admin_reservations_path, alert: "❌ Nie udało się usunąć rezerwacji!"
    end
  end

  def confirm
    if @reservation.update(status: "confirmed")
        ReservationMailer.confirmation(@reservation).deliver_later
        redirect_to admin_reservations_path, notice: "✅ Rezerwacja została potwierdzona!"
    else
        redirect_to admin_reservations_path, alert: "❌ Nie udało się potwierdzić rezerwacji!"
    end
  end

  def cancel
    if @reservation.update(status: "cancelled")
        # Sending cancellation email to the user
        ReservationMailer.cancellation(@reservation).deliver_later
        redirect_to admin_reservations_path, notice: "✅ Rezerwacja została anulowana!"
    else
        redirect_to admin_reservations_path, alert: "❌ Nie udało się anulować rezerwacji!"
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień administratora!"
    end
  end
end
