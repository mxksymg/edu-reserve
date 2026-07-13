# Inherits from WebApplicationController.
class Teacher::ReservationsController < WebApplicationController
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  # Checks whether the user has the teacher or admin role (private method)
  before_action :ensure_teacher!
  # Launch private method set_reservation before confirm and cancel actions
  before_action :set_reservation, only: [ :confirm, :cancel ]


    def index
      @reservations = Reservation.joins(schedule: :course).where(schedules: { teacher_id: current_user.id })
                                .includes(:user, schedule: :course)


      if params[:status].present?
        @reservations = @reservations.where(status: params[:status])
      end

      @reservations = @reservations.order(created_at: :desc).paginate(page: params[:page], per_page: 20)
    end



  def confirm
    # Checks whether the teacher can confirm this reservation -> ReservationPolicy#confirm?.
    authorize @reservation, :confirm?
    # Attempts to change the reservation status to confirmed.
    if @reservation.update(status: "confirmed")
      # ReservationMailer - name of the mailer class that you created. It contains the confirmation method, which prepares the email.
      # .confirmation(@reservation) - calls the confirmation method on the ReservationMailer class. Passes the reservation
      # object (@reservation) to it. Returns a mail object (ready to be sent).
      # How deliver_later works. Rails does not send the email immediately. Instead, it stores the job in a queue. Sidekiq
      # receives the job. Sidekiq is a separate process that continuously checks whether there are new jobs in the queue.
      # When it finds an email job, it executes it, meaning it connects to the SMTP server and sends the email. The user
      # does not wait. The application immediately returns a response (e.g. JSON confirmation).
      ReservationMailer.confirmation(@reservation).deliver_later
      redirect_to teacher_calendar_event_path(@reservation.schedule), notice: "✅ Rezerwacja została potwierdzona!"
    else
      redirect_to teacher_calendar_event_path(@reservation.schedule), alert: "❌ Nie udało się potwierdzić rezerwacji."
    end
  end

  def cancel
    # Checks whether the teacher can cancel this reservation -> ReservationPolicy#cancel?.
    authorize @reservation, :cancel?
    # Attempts to change the reservation status to cancelled.
    if @reservation.update(status: "cancelled")
      redirect_to teacher_calendar_event_path(@reservation.schedule), notice: "❌ Rezerwacja została anulowana!"
    else
      redirect_to teacher_calendar_event_path(@reservation.schedule), alert: "❌ Nie udało się anulować rezerwacji."
    end
  end

  private

  def set_reservation
    # Finds the reservation in the database by ID. params[:id] – comes from the URL (/teacher/reservations/1/confirm).
    @reservation = Reservation.find(params[:id])
  end

  def ensure_teacher!
    unless current_user.teacher? || current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień nauczyciela!"
    end
  end
end
