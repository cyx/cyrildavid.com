## The Basics

If you haven't tried the simplest thing that could possibly work
in order to write the infamous "Hello World" using just Rack,
then now's the time to start.

<pre class="prettyprint">
gem install rack
mkdir helloworld && cd helloworld
vi config.ru
</pre>

Now start hacking away (use your favorite editor in place of vi in case
you're more comfortable with something else).

<pre class="prettyprint">
app = lambda { |env|
  [200, { "Content-Type" => "text/plain", ["Hello World"]]  
}

run app
</pre>


Rack's protocol is very simple:

1. Your app can be any object that responds to `call`.
2. Rack passes in the request environment as a hash.
3. You respond with a tuple consisting of the HTTP status (200 for success), 
   the headers, and an object responding to `each` (hence the array).

Now that we've finished that, let's quickly test that everything works!

<pre class="prettyprint">
rackup -D -P rack.pid # start the server in localhost:9292

# Now let's do a bit of bash and curl to verify our assertion
test "Hello World" == "$(curl --silent http://localhost:9292)" || echo "failed"
</pre>

If everything succeeded, you should see nothing. Otherwise you'll see
the string "failed".

Now let's quickly stop our server, just to be tidy. 

<pre class="prettyprint">
kill -9 $(cat rack.pid) && rm rack.pid # stop our rackup server
</pre>

## So that's great and all, but what does that have to do with anything?

Well, as with most things, it's best to know everything from the ground up.

Let's begin with a more complicated, albeit still trivial example. 

- When you go to the homepage (`/`, you'll see hello world)
- When you go to `/datetime`, you'll see the current date and time.

We can implement that in a couple of different ways. Let's do it using
our old friend, the `switch` statement.

<pre class="prettyprint">
class Hello
  def self.call(env)
    case env["PATH_INFO"]
    when "/" 
      [200, { "Content-Type" => "text/plain" }, ["Hello World"]]
    when "/datetime"
      [200, { "Content-Type" => "text/plain" }, [Time.now.rfc2822]]
    else
      [404, { "Content-Type" => "text/plain" }, ["404 Not Found"]]
    end
  end
end

run Hello
</pre>

Let's verify that we have met the requirements.

<pre class="prettyprint">
rackup -D -P rack.pid

test "$(ruby -r time -e 'puts Time.now.rfc2822')" \
  == "$(curl --silent http://localhost:9292/datetime)" || echo "failed"

test "404 Not Found" 
  == "$(curl --silent http://localhost:9292/missing)" || echo "failed"

kill -9 $(cat rack.pid) && rm rack.pid
</pre>

## Refactor: use Rack's built in classes

Now that we've made it work, how about we clean it up a bit.

<pre class="prettyprint">
class Hello
  def self.call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    case req.path
    when "/" 
      res.write "Hello World"
    when "/datetime"
      res.write Time.now.rfc2822
    else
      res.status = 404
      res.write "404 Not Found"
    end

    res.finish
  end
end

run Hello
</pre>

## Exercise: build a simple sinatra clone

Of course we can't build every single feature of Sinatra,
but we can try to trim down the requirements to only
the following:

1. Allow the user to handle GET/PUT/POST/DELETE requests
2. Allow the user to specify path matchers (e.g. /hello/:name)
3. The last string in the handler will be the response.

Here we go! Let's meet our new baby Frank.

<pre class="prettyprint">
class Frank
  def self.get(path, &block)
    handlers["GET"] << [matcher(path), block]
  end

  def self.post(path, &block)
    handlers["POST"] << [matcher(path), block]
  end

  def self.put(path, &block)
    handlers["PUT"] << [matcher(path), block]
  end

  def self.delete(path, &block)
    handlers["DELETE"] << [matcher(path), block]
  end
  
  def self.matcher(path)
    # handle the case where the path has a variable e.g. /post/:id
    re = path.gsub(/\:[^\/]+/, "([^\\/]+)")

    %r{\A#{re}\z}
  end

  def self.handlers
    @handlers ||= Hash.new { |h, k| h[k] = [] }
  end
 
  def self.call(env)
    res = Rack::Response.new

    handlers[env["REQUEST_METHOD"]].each do |matcher, block|
      if match = env["PATH_INFO"].match(matcher)
        break res.write(block.call(*match.captures))
      end
    end
  
    res.status = 404 if res.empty?
    res.finish
  end
end
</pre>

## Frank in action

We'll build a very contrived example where we can do our
old actions (hello world and the datetime), but in addition,
we can:

1. POST /hello/_[your name]_
2. PUT /hello/_[your old name]/[your new name]_
3. DELETE /hello/_[your name]_


<pre class="prettyprint">
class Hello < Frank
  get "/" do
    "Hello World"    
  end

  get "/datetime" do
    Time.now.rfc2822
  end

  get "/hello/:name" do |name|
    "Hello #{name}"
  end

  post "/hello/:name" do |name|
    "#{name} added."
  end

  put "/hello/:src/:dst" do |src, dst|
    "#{src} renamed to #{dst}."
  end

  delete "/hello/:name" do |name|
    "#{name} removed."
  end
end

run Hello
</pre>

## Conclusion

The point of all these examples is to simply illustrate the
power of Rack in and of itself, and to also serve as an eye-opener
to the power of plain 'ol ruby and it's best library Rack.
