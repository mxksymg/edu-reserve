class Web::ReservationsController < WebApplicationController
  def create
    # Finds the schedule in the database by ID. params[:schedule_id] – comes from the form.
    @schedule = Schedule.find(params[:schedule_id])
    # current_user.reservations.new – creates a reservation associated with the user. It does not save it to the database yet.
    @reservation = current_user.reservations.new(schedule: @schedule, status: "pending")
    # Attempts to save the reservation to the database.
    if @reservation.save
        # ReservationMailer - name of the mailer class that you created. It contains the confirmation method, which prepares
        # the email.
        # .confirmation(@reservation) - calls the confirmation method on the ReservationMailer class. Passes the reservation
        # object (@reservation) to it. Returns a mail object (ready to be sent).
        # How deliver_later works. Rails does not send the email immediately. Instead, it stores the job in a queue. Sidekiq
        # receives the job. Sidekiq is a separate process that continuously checks whether there are new jobs in the queue.
        # When it finds an email job, it executes it, meaning it connects to the SMTP server and sends the email. The user
        # does not wait. The application immediately returns a response (e.g. JSON confirmation).
        ReservationMailer.confirmation(@reservation).deliver_later
        redirect_to course_path(@schedule.course), notice: "✅ Rezerwacja została utworzona! Oczekuje na potwierdzenie."
    else
        error_messages = @reservation.errors.full_messages.join(", ")
        redirect_to course_path(@schedule.course), alert: "❌ #{error_messages}"
    end
  end
end
