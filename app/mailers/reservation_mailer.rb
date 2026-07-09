# Defines the ReservationMailer class which inherits from ApplicationMailer.
# ApplicationMailer is the base mailer that contains shared settings (e.g. the sender's email address).
class ReservationMailer < ApplicationMailer
    # Defines the confirmation method, which accepts one argument (the reservation object).
    # This method will be called when we want to send a reservation confirmation email.
    def confirmation(reservation)
        # Stores the reservation object in the variable @reservation. This makes it available in the mailer view.
        @reservation = reservation
        # Retrieves the user associated with the reservation. It will be used to retrieve the email address and name.
        @user = reservation.user
        # Retrieves the schedule associated with the reservation. It will be used to display the date, time, and room.
        @schedule = reservation.schedule
        # Retrieves the course associated with the schedule. It will be used to display the course name.
        @course = @schedule.course
        # mail –  method from ApplicationMailer that actually sends the email. Accepts a hash of options, where :to and :subject
        # are the most basic ones. The other one are here :from, :cc, and :reply_to
        # to: @user.email – the recipient's address (the user's email).
        # subject: – sets the email subject. #{} – inserts the value of a variable or expression into a string.
        mail(to: @user.email, subject: "Potwierdzenie rezerwacji - #{@course.name}")
    end
end
