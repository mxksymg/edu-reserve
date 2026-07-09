# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer_mailer
class ReservationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reservation_mailer_mailer/confirmation
  def confirmation
    ReservationMailer.confirmation
  end
end
