# Valid? & Invalid? in Ruby
# Validation

Have you ever wondered how come your favourite application knew your password is weak or worse, your username is already taken?!

If you have seen those annoying notifications saying you need such and such for your password to qualify, then you have been a victim of validation.

Definition: Validation
>To establish the soundness, accuracy, or legitimacy of something.

Record validation in ruby is a mechanism for checking the accuracy of data in your ruby API or application.

Validation is a necessary and extremely significant step to integrate into any meaningful application.

The repercussions of invalid data are far-reaching with devastating blow-ups in business processes, survival, continuity, etc...

Building any thorough validation system is cumbersome and requires one to think out of the box if not at least play "user" of their application and emulate how extremely a user might tinker with it.

The good news is, in the world of Ruby and Ruby on Rails, validations can be achieved without breaking much of a sweat.

In this article we are going to look at how you can use `valid?` and `invalid?` to perform validations in your RoR application.

In Rails, whenever `create, create!, save, save!, update, or update!` is invoked, validations are triggered. These methods will only save data to the database if the data provided is valid.

It is important to note that validations by default run before the database commands associated with the methods mentioned are sent to the database.

For instance, `create` which corresponds to SQL's `INSERT` command will invoke validations on an entity before performing the actual `INSERT` operation.


In the following steps, I am assuming you have set up your ruby environment and installed the necessary gems for a rails application.

In your terminal run:

```ruby
rails new validation --api --minimal
```

The command above will create a new resource. On successful completion:

Move to the project directory:

```
cd validations
```

Open the directory in vs-code:

```
code .
```

If everything worked out well, you should have a folder structure similar to this:


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6fi4b1xsb6f72ltzv2z7.png)

Let us build a Person class and use it to demonstrate how validations work in rails.

Still on the terminal in the same project folder run:

```
rails g resource Person name email phone
```

This command will generate:
1.  Person model
2.  Person controller
3.  routes
4.  Run migrations
5.  Other files are not necessary for this tutorial

Go to ``` app/models/person.rb ```

```ruby
    # app/models/person.rb
    class Person < ApplicationRecord

    end
```
As you can see, our model does not have any code yet.

On the terminal, let us run: `rails c` to start an interactive rails console

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/demrpn9fn4qe2j0shq9v.png)

Let us create a `Person p` by running the following command

```
p = Person.create
```

On the terminal, you should see this:


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/9k618wwwuva5fzci93ra.png)

This command ran successfully and we have created one Person!

Let us have a look at the person by running `p`

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/k5vbvasdmrwehr9q8nci.png)

But wait... why is it that the person does not have not any data i.e everything except the `id` is `nil`?

Well, running the `Person.create` triggered an `INSERT` command which initiated the insert process on our database.

Since we did not have any checks in place to validate our data, the "useless" record was deemed valid and thus accepted and saved without raising any errors or exceptions.

I will leave it to your imagination what will happen if you pull this data and try to display it on your front-end app.

Now let us add some code to our models to constrain the data we receive and permit:

```ruby
# app/models/person.rb
class Person < ApplicationRecord
  validates :username, presence: true # no blank
  validates :email, presence: true, uniqueness: true # no blank, no duplicates
  validates :phone, length: {is: 10} # must be EXACTLY 10 characters long
end
```

In the above snippet, we are adding validation to ensure:

- The entity data must contain a username, not blank
- It must have an email and the email must be unique
- The phone number must be exactly 10 digits no more no less

Reload the terminal by running `reload!`

Try running the same command i.e `Person.create` again:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4675efrxlvewlyrcc5lk.png)

As you can see, this process did not run to completion successfully. This can easily be confirmed by that read error that says `rollback transaction` which means the entity was not persisted to the database.

## Why?

Well, our guards and the validations ensured that we do not allow useless data in our application.

This is what went down:

1. Run the `Peron.create` method
2. Validations are invoked
3. Check if name is valid => `false`
4. Check if email is valid => `false`
5. Check if phone is valid => `false`
6. Verdict: Invalid object. Do not save!

This means the `INSERT` command was never invoked.

## How did rails know this?
Well, under the hood, every entity has an `errors` object associated with it.

If the object has any errors, the implication is that that entity is invalid. Otherwise, it is valid.

Let us check out this `errors` object.

Still, on the terminal, let us run `p.errors`

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/i3mhsu55oaszbu6de8fq.png)

We get the shape of the object but it is not quite readable

Run:

```
p.errors.full_messages
```

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7ivmu4qhci523la56lva.png)

## valid? and invalid?

As we have learned, validation will be triggered automatically whenever any of the following methods are invoked:

- create
- create!
- save
- save!
- update
- update!

However, we sometimes wish to manually run the validations.

To achieve this, `valid?` and `invalid?` are our go-to methods.

`valid?`

- This method returns `true` if an entity is valid and false otherwise.


`invalid?`

- This method returns `false` if an entity is valid and false otherwise.

Both of these methods perform a check on the `errors` object associated with the entity it was invoked on. If the object has any errors, the `valid?` return `true`.

The `valid?` method returns `false` to indicate that the entity is invalid and thus cannot be saved to the database. The opposite is true.

## How to use `valid?` and `invalid?`

Going back to our Person controller, we can add corresponding logic as follows:

```ruby
class PeopleController < ApplicationController
  def create
     # create person
     person = Person.create(username: params[:username], email: params[:email], phone: params[:phone])

    if person.valid? # if no errors in errors object
      # return user created to the client
      render json: person, status: :created
    else
      # otherwise let them know what went wrong
      render json: {errors: person.errors.full_messages}, status: :unprocessable_entity
    end
  end
end

```

Let us give it a test drive using [Postman](https://www.postman.com/)

Start by running `rails s` or `rails server` on the terminal

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dphk4b909d5tx0wj6zrp.png)

Copy the link `http://127.0.0.1:3000` and paste it on Postman address and a `/persons` and ensure that your Postman interface looks as shown below:


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ojxhclg9ktbhjo3l3ubd.png)

Here is the sample data I am using:

```json
{
    "username": "hermitex",
    "email": "hermitex@gmail.com",
    "phone": "0765568854"
}
```

Click on `Send`

Here is the response:

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/1n164li3ws9zqtvoaqp5.png)

Let us try to POST an invalid person

```json
{
    "username": "",
    "email": "hermitex@gmail.com",
    "phone": "0765568854"
}
```

Notice that we have intentionally sent  `""` value for `username` and
repeated the `email`

By definition, this entity is invalid since our validation logic does not allow duplicate emails and the username must not be blank. Remember?

Let us see what we get.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/61dbvky2at6gkrc77vbr.png)

There we go!

We have not only successfully prevented an invalid `INSERT` operation but also responded with appropriate messages and statuses to let the user know what might have gone wrong with their request.


## Summary
- Validation is a way of ensuring data accuracy and integrity
- In rails validation can be performed using helper methods like `validates`
- The following active records methods trigger validations:
  - create
  - create!
  - save
  - save!
  - update
  - update!
- To trigger validations manually, we can use
  - valid? or
  - invalid?
- Rails knows whether an entity is valid or not by checking the errors object associated with each entity
- Presence of an error in the errors object signifies that the object is invalid and valid otherwise

Well, validations can be customized to become complex depending on the use case[s]

Learn more about how this can be done [here](https://guides.rubyonrails.org/active_record_validations.html)
