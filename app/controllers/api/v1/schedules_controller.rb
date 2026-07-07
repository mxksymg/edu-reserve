# Defines the SchedulesController within the Api::V1 namespace.
# Inherits from ApplicationController, so it has access to methods such as authenticate_user! and authorize.
class Api::V1::SchedulesController < ApplicationController
    # Requires the user to be logged in before executing any action
    before_action :authenticate_user!
    # Runs the set_schedule (private) method before the show, update and destroy actions
    before_action :set_schedule, only: [ :show, :update, :destroy ]
    # GET /api/v1/schedule
    def index
        # Schedule.all - retrieves all records from the schedule table in the database
        @schedules = Schedule.all
        # Can the user view the list of schedules? -> SchedulePolicy#index?
        authorize @schedules
        # Returns JSON type format with @schedules - list of schedules and HTTP 200 OK status code
        render json: @schedules, status: :ok
    end
    # GET /api/v1/schedule/:id
    def show
        # Can the user view the details of a schedule? -> SchedulePolicy#show?
        authorize @schedule
        render json: @schedule, status: :ok
    end
    # POST /api/v1/schedule
    def create
        # @schedule = Schedule.new(schedule_params) - creates a new Schedule object in memory without saving it to the database.
        # schedule_params - private method
        @schedule = Schedule.new(schedule_params)
        # Can the user create a new schedule?-> SchedulePolicy#create?
        authorize @schedule
        # Trying save Schedule object into database
        if @schedule.save
            # status: :created - sets the HTTP status code to 201 Created, the standard response for a successfully created resource.
            render json: @schedule, status: :created
        else
            # @schedule.errors.full_messages - returns an array of error messages (e.g. ["Name can't be blank"]).
            # status: :unprocessable_entity - sets the HTTP status code to 422 Unprocessable Entity, indicating that the request is
            # sort of valid but contains invalid or unprocessable data
            render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
        end
    end
    # PATCH /api/v1/schedule/:id
    def update
        # Can the user update this schedule? -> SchedulePolicy#update?
        authorize @schedule
        # @schedule is an existing schedule object that was previously loaded by the set_school method
        # .update(schedule_params) attempts to update the object with the permitted parameters from school_params and save the changes to the database
        if @schedule.update(schedule_params)
            render json: @schedule, status: :ok
        else
            render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
        end
    end
    # DELETE /api/v1/schedule/:id
    def destroy
        # Can the user delete this schedule? -> SchedulePolicy#destroy?
        authorize @schedule
        @schedule.destroy
        head :no_content
    end

    private

    def set_schedule
        # @schedule = Schedule.find(params[:id]) - finds the schedule with the ID provided in the URL (e.g. /api/v1/schedule/5) and
        # stores the resulting object in the @schedule instance variable
        @schedule = Schedule.find(params[:id])
        # rescue ActiveRecord::RecordNotFound - if no schedule with the specified ID exists, Rails raises an ActiveRecord::RecordNotFound
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Schedule not found" }, status: :not_found
        end

    def schedule_params
        # params.require(:schedule) - requires the request payload to include a :schedule key (e.g.{ "schedule": { ... } }).
        # If the key is missing, Rails raises an exception.
        # .permit(:weekday, ...) - permits only the following attributes: weekday, start_time, end_time, room, course_id and teacher_id
        params.require(:schedule).permit(:weekday, :start_time, :end_time, :room, :course_id, :teacher_id)
    end
end
