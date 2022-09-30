class PeopleController < ApplicationController
  def create
     # create person
     person = Person.create(username: params[:username], email: params[:email], phone: params[:phone])

    if !person.invalid? # or person.valid?
       # if no errors in errors object
      # return user created to the client
      render json: person, status: :created
    else
      # otherwise let them know what went wrong
      render json: {errors: person.errors.full_messages}, status: :unprocessable_entity
    end
  end
end

