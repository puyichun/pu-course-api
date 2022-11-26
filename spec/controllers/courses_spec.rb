require 'rails_helper'

RSpec.describe Api::V1::CoursesController, type: :controller do
  
  it 'index' do
    get :index
    expect(response).to have_http_status(200)
  end

  it 'show' do
    course = FactoryBot.create(:course)
    get :show, params: { id: course.id }
    expect(response).to have_http_status(200)
  end

    describe 'create' do 
      it 'creates record' do
        expect {
          post :create,params: { course: { name: "COURSE課程", teacher: "mike", description: "This is course!!!" },
          chapter: [{ name: "第1章",
                      unit: [{
                        name: "first unit", description: "this is unit", content: "the first class unit"}]}]}
        }.to change(Course, :count).by(1)
      end
      context 'course name & teacher can not be blank' do
        before do
          post :create, params: { course: { name: "", teacher: "", description: "This is course!!!" },
          chapter: [{ name: "第1章",
                      unit: [{
                        name: "first unit",    description: "this is unit", content: "the first class unit"}]}]}                 
        end

        it 'returns a unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'course name blank errors_message' do
          expect(response.body).to eq("{\"course_errors\":[\"Name can't be blank\",\"Teacher can't be blank\"]}")
        end
      end

      context 'chapter name can not be blank' do

        before do
          post :create, params: { course: { name: "hello", teacher: "mike", description: "This is course!!!" },
          chapter: [{ name: "",
                      unit: [{
                        name: "first unit",    description: "this is unit", content: "the first class unit"}]}]}                 
        end

        it 'returns a unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'chapter name blank errors_message' do
          expect(response.body).to eq("{\"chapter_errors\":[\"Name can't be blank\"]}")
        end
      end

      context 'unit name & content  can not be blank' do

        before do
          post :create, params: { course: { name: "hello", teacher: "mike", description: "This is course!!!" },
          chapter: [{ name: "第1章",
                      unit: [{
                        name: "", description: "this is unit", content: ""}]}]}                 
        end

        it 'returns a unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'unit name blank errors_message' do
          expect(response.body).to eq("{\"unit_errors\":[\"Name can't be blank\",\"Content can't be blank\"]}")
        end
      end

    end

    describe 'update' do
      course = FactoryBot.create(:course)
      chapter_one = course.chapters.create(name: "chapter_one")
      chapter_two = course.chapters.create(name: "chapter_two")
      unit_one = chapter_one.units.create(name: "unit_one",content: "unit_one")
      unit_two = chapter_one.units.create(name: "unit_two",content: "unit_two")
      before do
        patch :update, params: { id: course.id,course: { name: "hey", teacher: "mao",description: "Hey Apple ! " },
                              chapter: { name: "update_chapter", position: 1,id: chapter_two.id },
                              unit: { name: "update_unit",description: "the unit",content: "update_unit", position: 2, id: unit_one.id }
      }
      end
      
      it 'update record' do
        course.reload
        expect(course.name).to eq("hey")
      end

      it 'chapter position can be change' do
        chapter_two.reload
        expect(chapter_two.position).to eq(1)
      end

      it 'other chapter position will change' do
        chapter_one.reload
        expect(chapter_one.position).to eq(2)
      end

      it 'unit position can be change' do
        unit_one.reload
        expect(unit_one.position).to eq(2)
      end

      it 'other unit position will change' do
        unit_two.reload
        expect(unit_two.position).to eq(1)
      end





    end

    describe 'DELETE /destroy' do
    end

   
end