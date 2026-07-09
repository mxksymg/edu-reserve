class Api::V1::ReservationsController < ApplicationController
    # Requires the user to be logged in before executing any action
    before_action :authenticate_user!
    # Runs the set_reservation (private) method before the show, update and destroy actions
    before_action :set_reservation, only: [ :show, :destroy, :confirm ]

    def index
        # current_user.reservations - retrieves all reservations for the current user
        @reservations = current_user.reservations
        # Checks whether the user is allowed to view the list -> ReservationPolicy#index?
        authorize @reservations
        # Returns the list of reservations as JSON with a 200 status code.
        render json: @reservations, status: :ok
    end
    def show
        # Checks whether the user is allowed to view the details of a reservation -> ReservationPolicy#show?
        authorize @reservation
        render json: @reservation, status: :ok
    end
    def create
        # current_user.reservations.new - creates a new reservation for the current user without saving it to the database.
        # reservation_params - private method
        @reservation = current_user.reservations.new(reservation_params)
        # Checks whether the user can create a reservation -> ReservationPolicy#create?
        authorize @reservation
        # Trying save reservation object into database
        if @reservation.save
            # status: :created - sets the HTTP status code to 201 Created, the standard response for a successfully created resource.
            render json: @reservation, status: :created
        else
            # @reservation.errors.full_messages - returns an array of error messages.
            # status: :unprocessable_entity - sets the HTTP status code to 422 Unprocessable Entity, indicating that the request is
            # sort of valid but contains invalid or unprocessable data
            render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
        end
    end
    def destroy
        # Checks whether the user can delete the reservation -> ReservationPolicy#destroy?.
        authorize @reservation
        @reservation.destroy
        head :no_content
    end
    def confirm
        # Checks whether the current user has permission to confirm this reservation.
        # :confirm? – method in the ReservationPolicy that determines who is allowed to confirm reservations.
        authorize @reservation, :confirm?
        # Attempts to update the reservation – changes the status to 'confirmed'
        if @reservation.update(status: "confirmed")
            # ReservationMailer - name of the mailer class that you created. It contains the confirmation method, which prepares
            # the email.
            # .confirmation(@reservation) - calls the confirmation method on the ReservationMailer class. Passes the reservation
            # object (@reservation) to it. Returns a mail object (ready to be sent).
            # How deliver_later works. Rails does not send the email immediately. Instead, it stores the job in a queue. Sidekiq
            # receives the job. Sidekiq is a separate process that continuously checks whether there are new jobs in the queue.
            # When it finds an email job, it executes it, meaning it connects to the SMTP server and sends the email. The user
            # does not wait. The application immediately returns a response (e.g. JSON confirmation).
            ReservationMailer.confirmation(@reservation).deliver_later # if @reservation.status_previously_changed?
            # if @reservation.status_previously_changed? - avoid sending the email every time the status changes to confirmed
            render json: @reservation, status: :ok
        else
            render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def set_reservation
        # @reservation = Reservation.find(params[:id]) - finds the reservation with the ID provided in the URL (e.g. /api/v1/reservation/5) and
        # stores the resulting object in the @reservation instance variable
        @reservation = Reservation.find(params[:id])
        # rescue ActiveRecord::RecordNotFound - if no reservation with the specified ID exists, Rails raises an ActiveRecord::RecordNotFound
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Reservation not found" }, status: :not_found
        end

    def reservation_params
        # params.require(:reservation) - requires the request payload to include a :reservation key (e.g.{ "reservation": { ... } }).
        # If the key is missing, Rails raises an exception.
        # .permit(:schedule_id, ...) - permits only the following attributes: schedule_id and status.
        params.require(:reservation).permit(:schedule_id, :status)
    end
end
