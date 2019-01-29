# Creating Your Own API
We've looked at connecting React apps to an external API, and seen how to use data from an API to build compelling front end applications.  Today we're going to build our own API that will serve the data we create to our front end. 

Creating our own API opens up a new world of possibilities for building engaging, interactive applications.  We can begin to accept user input, store and manipulate that input in the backend, and then provide a personalized experience for our user, perfectly suited to the task he/she is trying to achieve.

As you've seen, the primary tool to collect input from users is an HTML form.  The user fills in form fields with information that allows them to interact with the application.  As a general rule, we always want to process, validate, and store user data on the server where we have more control and processing power to handle it.  To do so, we need to build an API that the React app can both send data to and receive data from.  Ruby on Rails is a fantastic platform to build just such an API, and is what we'll use in class.  There are many other options for building back end APIs.

In the architecture we are building, our front and backend will be two separate applications, giving us more freedom to choose the tools and technologies we want.  Throughout your career as a developer, you'll interact with many other backend platforms.  APIs can be built using Ruby, PHP, Python, Java, and even Javascript, among many others.  That might seem overwhelming, but remember that the concepts are generally the same no matter what technology is used.  The server is where we process data sent by the frontend, clean and store that data, and serve updated data back to the front end app to be consumed by the user.

## Review APIs
![Api](https://s3.amazonaws.com/learn-site/curriculum/React/api.jpeg)


## Building an API for Cat Tinder
We're going to build an application to help our users' cats socialize and be well adjusted members of the feline community.  Our application will allow users to create profiles for their cats, search other cat profiles and setup kitty play dates.  In this module we're focusing on the server side, so let's jump in and start building an application.

## Overview of goals
* Setting up a Ruby on Rails API application
* Creating endpoints to accept and serve data
* Validating user input

# App setup
By the end of this section, you'll have a Rails app setup as an API with one test route.  You'll be able to receive JSON requests, and respond with data encoded in JSON format.

## Let's get started
We're going to use the ```--api``` flag when building a new Rails application to customize our new Rails app to have just what we need.  The app communicates in JSON, instead of HTML/CSS/Javascript, so we don't need to clutter the app up with support for all of those file types.  Open up a command line prompt, and enter the following commands:

```
$ gem install rails
$ rails new cat_tinder_backend --api -T --database=postgresql
$ cd cat_tinder_backend
```
This gets the latest and greatest version of Rails, and generates a new Rails application configured to be used as an API.  the ```-T``` flag tells rails to skip adding the default Minitest framework, as we're going to use Rspec instead.

````
$ echo "gem 'rspec-rails', groups: [:development, :test]" >> Gemfile
$ bundle install
$ rails generate rspec:install
```
This adds 'rspec-rails' to the Gemfile, and instructs Rails to only load rspec when we are in development or test mode, and not production.  The ```rails g rspec:install``` command installs all the necessary files to create and run our tests.

Next its time to add a Cat resource.  The following command will add the Model, Migration, Controller, and Route for cats.
```
$ rails g resource cat name:string age:integer enjoys:text
$ rake db:create db:migrate
````

## Verify that we're all set up
Let's take a look around the application and verify that everything is setup correctly.  The first thing we can do is see that our test suite is running.  Of course, we don't have any specs yet, so we won't get much feedback, but rspec itself should run and finish successfully:

```
$ rspec spec
*

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) Cat add some examples to (or delete) .../cat_tinder_backend/spec/models/cat_spec.rb
     # Not yet implemented
     # ./spec/models/cat_spec.rb:4


Finished in 0.01159 seconds (files took 2.77 seconds to load)
1 example, 0 failures, 1 pending
```

Looks good!  If we open up Atom and inspect our app, we should see the following file structure:
![cat tinder files](https://s3.amazonaws.com/learn-site/curriculum/cat-tinder/cat_tinder_server_files.png)

Open up ```db/migrate/``` (yours will be named slightly different)

```Ruby
class CreateCats < ActiveRecord::Migration[5.1]
  def change
    create_table :cats do |t|
      t.string :name
      t.integer :age
      t.text :enjoys

      t.timestamps
    end
  end
end
```

If we look in ``` config/routes.rb ```, we should see our cats route there:

```ruby
Rails.application.routes.draw do
  resources :cats
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

With one last check, we can be pretty confident that everything is setup correctly.  Let's fire up a Rails console, and interact with the database:

```
$ rails c
Running via Spring preloader in process 22833
Loading development environment (Rails 5.1.5)
2.4.1 :001 > Cat.create(name: 'Felix', age: 4, enjoys: 'Window ledges, being in charge, and cat food, lots and lots of cat food.')
   (0.1ms)  begin transaction
  SQL (1.3ms)  INSERT INTO "cats" ("name", "age", "enjoys", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["name", "Felix"], ["age", 4], ["enjoys", "Window ledges, being in charge, and cat food, lots and lots of cat food."], ["created_at", "2018-03-09 16:01:41.355922"], ["updated_at", "2018-03-09 16:01:41.355922"]]
   (1.1ms)  commit transaction
 => #<Cat id: 1, name: "Felix", age: 4, enjoys: "Window ledges, being in charge, and cat food, lots...", created_at: "2018-03-09 16:01:41", updated_at: "2018-03-09 16:01:41">
2.4.1 :002 > Cat.all
  Cat Load (0.3ms)  SELECT  "cats".* FROM "cats" LIMIT ?  [["LIMIT", 11]]
 => #<ActiveRecord::Relation [#<Cat id: 1, name: "Felix", age: 4, enjoys: "Window ledges, being in charge, and cat food, lots...", created_at: "2018-03-09 16:01:41", updated_at: "2018-03-09 16:01:41">]>
2.4.1 :003 >
```

That looks great!  In the next step, we'll expose some endpoints in our API, so the frontend application has a way to communicate with all the functionality we've built out so far.

# Add some seeds
Seeds are some initial data loaded into the backend database that we can use to bootstrap our application. Rails comes with a seed.rb file, and a rake task that knows how to read that file and follow its instructions.  All we need to do to load up some data is add a few lines to ```db/seeds.rb``` and run ``` $ rake db:seed ``` from the command line.  One thing to keep in mind is that we want to be able to create new records the first time, but also when we run the seed command over and over again and have it update our records instead of creating more and more records.  This will allow us to make updates to our seeds, re-run the rake command, and have updated data in our database.  With a little thought, and by making use of some nifty tools that Rails provides, we can accomplish just this.

*** Idempotent ***
Btw, creating a task that updates instead of creates new records every time after the first time is called "idempotent" and its an interesting concept in programming and mathematics.  You can learn more about [idempotency here](http://whatis.techtarget.com/definition/idempotence)

#### db/seeds.rb
```ruby
cat_attributes = [
  {
    name: 'Felix',
    age: 2,
    enjoys: 'Long naps on the couch, and a warm fire.'
  },
  {
    name: 'Homer',
    age: 12,
    enjoys: 'Food mostly, really just food.'
  }
]

cat_attributes.each do |attributes|
  Cat.create(attributes)
end
```
Notice that this is just plain old Ruby code, we can put whatever we like in here, and every time we call ```rake db:seed``` it will be executed.

```
$ rake db:seed
```

# CORS
The last bit of housekeeping we need to do on the backend is enable CORS.  Our frontend and backend are running on two different servers.  Browsers have security built in to protect users from submitting their data to servers that they are not intending to, so we have to tell the frontend that the backend is indeed the correct place for it to be communicating with.

You can read more about CORS here:

* [MDN on CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS)
* [Wikipedia](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
* [NPM CORS package](https://www.npmjs.com/package/cors)

## Enable CORS in the backend app
When we created the Rails application with the ```--api``` flag, CORS support was automatically added for us, but disabled.  We need to enable it.  In your Gemfile, find this line:

```ruby
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
#gem 'rack-cors'
```

And uncomment the line beginning with 'gem', so it looks like this:

```ruby
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
```

Then, we need to enable CORS in the initializer by uncommenting its setup code, and changing what domain it allows requests to be sent from.  We'll use the wildcard '*' because we're in development.  When you take your app to prodution, you'll want to change this the URL that your frontend app is served from.

#### config/initializers/cors.rb
```ruby
# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # <- change this to allow requests from any domain while in development.

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```
Uncomment the config section above

## Bundle install

Finally, we run ```bundle install``` from the command line to install the proper gems

```
$ bundle install
```

That's it!  We can now accept POST, PUT, and DELETE requests in our server side application.

# API Endpoints

In the previous steps we generated a controller for Cats, but its pretty bare bones currently.  In fact, it doesn't actually have any routes at all!  Never fear, we're going to take care of that right now.  

```ruby
class CatsController < ApplicationController
end
```

Our app needs two routes to start, and index listing all the cats, and a 'create' route so that users can submit new cat information to the application.

## Routes for Cats

| URL | Method | Controller Method |
| /cats | get | index |
| /cats | post | create |

We can stub these methods into the controller now:

```ruby
class CatsController < ApplicationController
  def index
  end

  def create
  end
end
```

### Convention over Configuration
The name of these routes is important.  Rails knows to route the requests in the table above to the proper methods in our controller.  As long as we name the methods exactly as above, Rails will know what to do, and everything will work great.  If we were to ignore these conventions, our job would get very hard, very quickly, so let's stick with the 'Rails Way' of doing things, and make it easy on ourselves.


## Index route
We start with the index route.  In this endpoint, we want to return all of the cats that the application knows about.  Later on, we may want to add search and/or pagination, but for now we'll keep things simple and just return all the cats.

### Create a spec
We're going to practice Test Driven Development, so let's start with a test.  Create a new file ```spec/requests/cats_spec.rb```, and add this code:

```ruby
require 'rails_helper'

describe "Cats API" do
  it "gets a list of Cats" do
    # Create a new cat in the Test Database (not the same one as development)
    Cat.create(name: 'Felix', age: 2, enjoys: 'Walks in the park')

    # Make a request to the API
    get '/cats'

    # Convert the response into a Ruby Hash
    json = JSON.parse(response.body)

    # Assure that we got a successful response
    expect(response).to be_success

    # Assure that we got one result back as expected
    expect(json.length).to eq 1
  end
end
```

When we run that spec, it fails of course, because we don't have any code in the controller to respond to the request correctly.  This failure is a good thing!

```
$ rspec spec/requests/cats_spec.rb
F

Failures:

  1) Cats API gets a list of Cats
     Failure/Error: json = JSON.parse(response.body)

     JSON::ParserError:
       743: unexpected token at ''
     # ./spec/requests/cats_spec.rb:7:in `block (2 levels) in <top (required)>'

Finished in 0.09661 seconds (files took 1.15 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/requests/cats_spec.rb:4 # Cats API gets a list of Cats
```

Now we can write the controller code to make it pass:

```Ruby
def index
  cats = Cat.all
  render json: cats
end
```

Running our spec one more time, we see green!

```
$ rspec spec/requests/cats_spec.rb
.

Finished in 0.12364 seconds (files took 1.29 seconds to load)
1 example, 0 failures
```

### Try it in the browser
If you followed the setup in the last module, then you should already have a cat in your database to return.  You can add as many as you like using the Rails console ```$ rails c``` on the command line.  Start up the application, and navigate a browser to our new endpoint, we should see output similar to this:

![Cat Tinder Index](https://s3.amazonaws.com/learn-site/curriculum/cat-tinder/cat_tinder_index.png)

## The Create Route
Next we'll tackle the 'create' route.  Let's start with adding a new test:

```ruby
  it "creates a cat" do
    # The params we are going to send with the request
    cat_params = {
      cat: {
        name: 'Buster', 
        age: 4, 
        enjoys: 'Meow Mix, and plenty of sunshine.'
      }
    }

    # Send the request to the server
    post '/cats', params: cat_params

    # Assure that we get a success back
    expect(response).to be_success

    # Look up the cat we expect to be created in the Database
    new_cat = Cat.first

    # Assure that the created cat has the correct attributes
    expect(new_cat.name).to eq('Buster')
  end
```

And once again, this fails because we have no code in the controller to make it pass.  Good!

```
$ rspec spec/requests/cats_spec.rb
.F

Failures:

  1) Cats API creates a cat
     Failure/Error: expect(new_cat.name).to eq('Buster')

     NoMethodError:
       undefined method `name' for nil:NilClass
     # ./spec/requests/cats_spec.rb:24:in `block (2 levels) in <top (required)>'

Finished in 0.11318 seconds (files took 1.3 seconds to load)
2 examples, 1 failure

Failed examples:

rspec ./spec/requests/cats_spec.rb:12 # Cats API creates a cat
```

Adding the controller code for this spec is as follows:

```
  def create
    # Create a new cat
    cat = Cat.create(cat_params)

    # respond with our new cat
    render json: cat
  end

  # Handle strong parameters, so we are secure
  def cat_params
    params.require(:cat).permit(:name, :age, :enjoys)
  end
```

And we're Green!  This isn't quite production ready code, but its enough to get our first test of the endpoint to pass, which is what we're after, so we're happy.  

## Summary
In this section, we've built out our first API endpoint to handle requests for listing and creating cats.  In the next section, we're going to deal with validating that the information passed to the ```create``` route is what we expect and handle situations when its not.

# Getting Cats from the Database to the Frontend

Now, switching gears back over to our frontend, lets load our cats.

The frontend is going to ask the rails API for information, then rails will use ActiveRecord to get that information out of the database and hand it back to the frontend as json. We want to make that process as simple and re-useable as possible, because even though we only have two pages right now, we can be pretty sure our cat tinder app will get bigger and more complex in the future (because we're going to be famous). 

To do this, we are going to put all of our "calls" to the API in a new folder in our react app.

Add a new folder ``` src/api ```

Inside that folder, add a new file ``` index.js ```

Here is the code for index.js, read the code and comments.

```javascript
// the address of our rails backend, saved as a constant value, because we never want to accidently change it
const BASE = 'http://localhost:3000'

let getCats = function() {
  	// the function name getCats is intended to remind you of the restful rails route --> GET '/cats'. 
	return fetch(BASE + '/cats') // this would be equivalent to going to localhost:3000/cats in your browser. Do that - - what do you see?
		.then((resp) => {
           	// resp will be whatever you saw on the page localhost:3000/cats, it is the result of our fetch call
			let json = resp.json() // we want to make sure what we have is just the json part of the response
			console.log(json);
			return json
		})
}

export  {
	getCats
}
```

We are using the javascript Fetch API as the intermediary who carries our request to the backend. Like a courier, we just have to supply fetch with an address (our BASE const).  

Notice that we have wrapped the fetch call in another function called getCats. This is to give us control over WHEN the call runs. 

When we export something in React, we make it available for import (just like with all our components, the ```export default``` part)

So now, we can ```import``` our api call into any file we please. Lets do that:

First, add ``` import { getCats } from '../api' ``` to the imports in App.js

Then, add a new function to App.js:

#### in App.js
``` javascript
	constructor(props){
		super(props)
		this.state = {
			cats: []
		}
	}

	componentWillMount() {
		getCats()
		.then(APIcats => {
			this.setState({
				cats: APIcats
			})
		}
	}

```

What is this code doing? The big things to note are that we call getCats (which is a promise) and use the value returned from the promise (APIcats) to update state. ComponentWillMount is part of the React component lifecycle and always runs right before render. This means, that right before we 
have to show information on a page, React is going to preemptively use the code in our api folder to ask for some information and use the result from the 
database to set state. 

Now we should be ready to get information from the backend. Start your Rails server and react server at the same time, make sure to put the rails server on port 3000

Fire up your React server if its not already, and let's see how we're doing.  Recall the wireframe we started out with?

![wireframe](https://s3.amazonaws.com/learn-site/curriculum/cat-tinder/cat-tinder-wireframe.png)

This is where we've ended up:

![cat tinder index](https://s3.amazonaws.com/learn-site/curriculum/cat-tinder/cat-tinder-index.png)

__Excellent__!


# Validations
Let's take a look at when things don't go as we expect, when data is submitted to our API this isn't complete, or has something else that causes it to be invalid.  All data that we accept and commit to the database must not have the potential to cause our app to be unstable.  Its our job, no matter what, that our app responds in predictable ways to every request, and over many requests.  The primary tool we have to assure predictable results is to assure that the data we commit to our database is in a form that we expect it to be, and for this we use validations in a Rails application.  When the incoming data looks to be correct, we commit it, when it isn't correct, we reject it, and respond with a reason why it was not accepted.

## Adding our first validation
We've started all of our back end coding with a failing test, and we now have good test coverage of what we expect the api to do when it is passed good data.  What we need now is a test of what we expect it to do when passed bad data.  What happens when a user submits a cat without a name?  Do we accept it, or do we reject.  Same question goes for the cat's age and what he/she enjoys.  It may be acceptable to create a record without the enjoys data, but we should require an age.  Let's write a test for each of these cases.

### A Feature Test for Cat Name

Here's a test to assure that we get the correct response status when we submit a create request without a name for a cat:

#### spec/requests/cats_spec.rb
```
it "doesn't create a cat without a name" do
  cat_params = {
    cat: {
      age: 4, 
      enjoys: 'Meow Mix, and plenty of sunshine.'
    }
  }

  post '/cats', params: cat_params

  # This is a new test to make sure that our status is correct when the record can't be created
  # You can read more about HTTP response codes here: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
  expect(response.status).to eq 422

  # We also want to check that the API lets us know what is wrong, so the frontend can prompt the user to fix it.
  json = JSON.parse(response.body)
  # Errors are returned as an array because there could be more than one, if there are more than one validation failures on an attribute.
  expect(json['name']).to include "can't be blank"
end
```

And the results from running the full test suite:

```
$ rspec spec
*..F

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) Cat add some examples to (or delete) /Users/mclark/Projects/notch8/curriculum/2018-alpha/08-React-and-Rails/cat_tinder/spec/models/cat_spec.rb
     # Not yet implemented
     # ./spec/models/cat_spec.rb:4


Failures:

  1) Cats API doesn't create a cat without a name
     Failure/Error: expect(response.status).to eq 422

       expected: 422
            got: 200

       (compared using ==)
     # ./spec/requests/cats_spec.rb:36:in `block (2 levels) in <top (required)>'

Finished in 0.15078 seconds (files took 1.41 seconds to load)
4 examples, 1 failure, 1 pending

Failed examples:

rspec ./spec/requests/cats_spec.rb:27 # Cats API doesn't create a cat without a name
```

Great!  We expected a 422 response which is the server letting us know that we submitted an "Unprocessable Entity", but that's not what we got back.  So how do we make that test pass?  Let's add a validation.  You can also see in the above test results that we have a Pending test for our Cat model, and we know that validations are added to models, why don't we add another Model test for the validation, and make it pass?

### A model test for our validation

#### spec/models/cat_spec.rb
```
RSpec.describe Cat, type: :model do
  it "should validate name" do
    cat = Cat.create
    expect(cat.errors[:name]).to_not be_empty
  end
end
```

When we run that, we see the test fails, but we can make it pass with one line of code in the model

#### app/models/cat.rb
```
class Cat < ApplicationRecord
  #Here is the new line of code
  validates :name, presence: true
end
```
Green!  But... when we run our request spec, we can see that it is still failing.  What's going on?  Our cat isn't being created any longer, why is the controller action still returning a "success" response?  We still have some more code to write.  We need to check to see if the cat was created in the controller, and respond appropriatly if it wasn't.  We update the controller like this to get our request spec green:

#### app/controllers/cats_controller.rb
```
def create
  cat = Cat.create(cat_params)
  if cat.valid?
    render json: cat
   else
     render json: cat.errors, status: :unprocessable_entity
   end
end
```

And Now, we're Green!

Challenges:
Add the appropriate Validations to make sure that users submit an age, and what the cat enjoys.  
Add a Validation to assure that the enjoys value is at least 10 characters long.

# Creating a new cat 

We already have a getCats API call, so we need to make a new one called createCat to make our NewCat form work. 

The createCat fetch call is going to be a little bit different than getCats, because creating something in the rails requires a POST type HTTP request (think back to your rails routes). 

A POST type request means that we are "posting" or sending information along with the request. Information that must be handled. In this case, by specifying the HTTP verb `POST`, attaching some information, and directing it to the rails "/cats" route will mean that the attached information is used to create a new cat instance in the database.

Here is the code:

#### src/api/index.js
```javascript 
let createCat = function(cat) {
	return fetch(BASE + '/cats', {
		body: JSON.stringify(cat),  // <- we need to stringify the json for fetch
		headers: {  // <- We specify that we're sending JSON, and expect JSON back
			'Content-Type': 'application/json'
		},
		method: "POST"  // <- Here's our verb, so the correct endpoint is invoked on the server
	})
		.then((resp) => {
			let json = resp.json()

			return json
		})
}
```
Read that through a few times to see if you can get the gist of what's going on. Remember you will also need to export createCat to use this function elsewhere.

## Passing the New Cat information

Last bit to do is to connect the new cat form to the database, so that the information for a new cat submitted in a form is saved.  Recall that we're already passing the form data from NewCat to App.js on submit, so all that's left is to make App.js pass that information to the API.

#### src/App.js
```javascript
handleNewCat(newCatInfo) {
	createCat(newCatInfo)
    .then(successCat => {
        console.log("SUCCESS! New cat: ", successCat);
    })
}
```

## Redirecting after new cat success
Try that out, and you should see that you can now add new cats to the database, but there's one last thing we should do.  Users will expect to be redirected to the cat index page after they add a cat.  

To do this with the react-router, we need to add a ```<Redirect/>``` tag to the NewCat form component that will be triggered when we want to redirect.

But the big question is, how do we know when we want the redirect to happen? 

We could trigger the redirect after they hit submit, but what if there was an error while saving the cat to the database? The user would be redirected anyway and then wouldn't even know their cat hadn't been saved.

Instead, we need to be sure that a user is only redirected after a successfull save. That requires waiting for the ```createCat.then()``` in App.js. What we can do is create a message to ourselves that the cat was saved successfully - we can call it a flag. We'll call our flag newCatSuccess and save it into state. 

So, in App.js, update state to look like this:

```javascript
this.state = {
    cats: [],
    newCatSuccess: false
}
```
Now, we can update state to show that a cat was saved successfully. Add a new setState method in the .then of createCat()

#### src/App.js
```javascript
handleNewCat(newCatInfo) {
    console.log("New Cat TRY", newCatInfo)
    createCat(newCatInfo)
    .then(successCat => {
        console.log("CREATE SUCCESS!", successCat);
        this.setState({ 
            newCatSuccess: true
        })
    })
}
```

Last thing to do is add the redirect element in NewCat.js. You can do this a variety of ways, but here is one example:

#### pages/NewCat.js
```
// ... the NewCat form ...
		</form>
	{this.props.success &&
		<Redirect to="/cats" />
	}
</div>
```
Notice the ```this.props.success``` statement. If this evaluates to "true" the redirect will run. As long as it evaluates to "false", the program will act as if the redirect doesn't even exist. You will need to pass a "success" value in props to finish this functionality.

