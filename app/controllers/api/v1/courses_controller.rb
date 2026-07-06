class Api::V1::CoursesController < ApplicationController
    # Requires the user to be authenticated before performing any action. If the user is not authenticated (e.g. the JWT is missing or invalid)
    # the application returns an HTTP 401 Unauthorized response
    before_action :authenticate_user!
    # Runs the private method set_course before the show, update and destroy actions
    before_action :set_course, only: [ :show, :update, :destroy ]
    def index
        # Takes all courses
        @courses = Course.all
        # Checks whether the user is allowed to view the list of courses -> CoursePolicy#index?
        authorize @courses
        # Returns courses list in JSON format
        render json: @courses, status: :ok
    end
    def show
        # Checks whether the current user is allowed to view the details of this course -> CoursePolicy#show?
        authorize @course
        # @course is set by the set_course
        render json: @course, status: :ok
    end
    def create
        # @course = Course.new(course_params) - creates a new Coruse object in memory without saving it to the database.
        # course_params - private method
        @course = Course.new(course_params)
        # Checks whether the current user is allowed to create a course -> CoursePolicy#create?
        authorize @course
        # If the record is saved successfully, returns the created course with HTTP status 201 (Created). If validation fails,
        # returns validation errors with HTTP status 422 (Unprocessable Entity)
        if @course.save
            render json: @course, status: :created
        else
            render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        # Checks whether the current user is allowed to update this course -> CoursePolicy#update?
        authorize @course
        # @course is set by the set_course
        # .update(course_params) attempts to update the object with the permitted parameters from course_params and save the changes to the database
        if @course.update(course_params)
            render json: @course, status: :ok
        else
            render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
    end
    def destroy
        # @course is set by the set_course
        # Checks whether the current user is allowed to destory this course -> CoursePolicy#destory?
        authorize @course
        # Removes course from database
        @course.destroy
        # head - Rails method that returns an HTTP response without a response body (headers only).
        # :no_content - shorthand for the HTTP 204 No Content status code.
        # The server indicates that the request was successfully processed but does not return any response data.
        head :no_content
    end
    private
    def set_course
        # @course = Course.find(params[:id]) - finds the course with the ID provided in the URL (e.g. /api/v1/courses/5) and
        # stores the resulting object in the @course instance variable
        @course = Course.find(params[:id])
        # rescue ActiveRecord::RecordNotFound - if no course with the specified ID exists, Rails raises an ActiveRecord::RecordNotFound
        rescue ActiveRecord::RecordNotFound
            # Returns an HTTP 404 Not Found response with the message "Course not found"
            render json: { error: "Course not found" }, status: :not_found
        end
    def course_params
        # params.require(:course) - requires the request payload to include a :course key (e.g.{ "course": { ... } }).
        # If the key is missing, Rails raises an exception.
        # .permit(:name, ...) - permits only the following attributes: name, description, category, level, age_group ...
        params.require(:course).permit(:name, :description, :category, :level, :age_group, :duration, :price, :school_id, :teacher_id, :max_students)
    end
end
