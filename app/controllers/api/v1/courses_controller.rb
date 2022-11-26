class Api::V1::CoursesController < ApplicationController
  before_action :set_course, only: [:show, :update, :destroy]

  def index
    @courses = Chapter.all
    @chapters = @courses.map{ |chapter| {course: chapter.course.name,
                             chapter: chapter.name,
                             unit: chapter.units.map{ |unit| unit.name }
                             }}
    render json: { course: @courses,chapter: @chapters }, status: 200
  end

  def show
    @chapter = @course.chapters.map{ |chapter| { chapter: chapter,unit: chapter.units }}
    render json: { course: @course,chapters: @chapter }, status: 200
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      params[:chapter].each do |chapter_params|
        @chapter = @course.chapters.new(chapter_params.permit(:name))
        if @chapter.save
          chapter_params[:unit].each do |unit_params|
            @unit = @chapter.units.new(unit_params.permit(:name, :content, :description))
            if @unit.save
            else
              render json: { unit_errors: @unit.errors.full_messages }, status: :unprocessable_entity
            end
          end
        else
          render json: { chapter_errors: @chapter.errors.full_messages }, status: :unprocessable_entity
        end
        
      end
    else
      render json: { course_errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    render json: { course_errors: @course.errors.full_messages } if not @course.update(course_params)
    @chapter = @course.chapters.find(params[:chapter][:id])
    render json: { chapter_errors: @chapter.errors.full_messages }if not @chapter.update(chapter_params)
    @unit = Unit.find(params[:unit][:id])
    if @unit.chapter.course == @course
      render json: { unit_errors: @unit.errors.full_messages } if not @unit.update(unit_params)
    else
      render json: { errors: "此單元非本課程的單元" }
    end
    render json: { state: "課程修改成功" }, status: 200
  end

  def destroy
    if @course.destroy
      render json: { state: "課程刪除成功" }
    else
      render json: @course.errors.full_messages
    end
  end

  private

    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(:name, :teacher, :description)
    end

    def chapter_params
      params.require(:chapter).permit(:name,:position,:id)
    end

    def unit_params
      params.require(:unit).permit(:name, :content, :description, :position,:id)
    end
end
