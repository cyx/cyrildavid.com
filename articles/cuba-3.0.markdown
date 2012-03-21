## A bit of history

We've been using Cuba for a little over a year now. It started out as
an experiment to see how far we can go without Sinatra, and eventually
grew into a more mature and stable microframework which we use for
any kind of web application we need to build. A couple of example sites
built on it include [Redis.io][redis-io], [openredis][openredis], and
a ton of other applications I fortunately can't disclose information
about.

While it might seem too lightweight for some, we see it as an advantage
more than a disadvantage.

## A new plugin architecture

By using it for every application we build, we've come across a couple
of neat patterns for adding simple plugins on top of the core runtime.

The plugin architecture is partly inspired by Sequel's approach to plugins.
It's pretty simple to get started, but is also flexible enough to handle
more complicated scenarios.

A simple plugin might look like:

<pre class="prettyprint">
module MyOwnHelper
  def markdown(str)
    BlueCloth.new(str).to_html
  end
end

Cuba.plugin MyOwnHelper
</pre>

You might argue that it's simply syntactic sugar for doing
`Cuba.send :include, MyOwnHelper`, but it also packs a couple more hidden
features you can optionally tap into:

1. If your module has a `ClassMethods` module available, it will be
   `extend`ed into Cuba.
2. If your module has a `::setup` method, it will be called after included.


<pre class="prettyprint">
An example that uses setup might look like:
module Render
  def self.setup(app)
    app.settings[:template_engine] = "erb"
  end

  def partial(template, locals = {})
    render("#{template}.#{settings[:template_engine]}", locals)
  end
end

Cuba.plugin Render
</pre>

The only thing worth noting here is the use of `settings`, which I'll
talk about next.

## Plugin architecture + state == Cuba.settings

We experimented with a few different approaches here, doing a `set` + `get`
approach for one, but then eventually ended up with a cleaner and more
sandboxed way of doing settings by simply providing a Hash you can use to
for storing some plugin information.

The __main advantage__ was that we __don't pollute__ the class namespace of 
Cuba with plugin related information.

Using it is the same as using any ordinary hash, and typically is initialized
per plugin via the `::setup` method of your plugin module.


## Performance as a side-effect of being simple

We never really targetted to be the fastest web framework in Ruby land,
and we're not sure if we are. The wonderful thing about it is that by
trying to focus on the simplest implementation, we get performance as a
nice added bonus.

Here's a summary of the performance times for 4 different
[helloworld shootout][shootout] apps:

[shootout]: http://github.com/cyx/shootout
[redis-io]: http://redis.io/
[openredis]: http://openredis.com/


<pre>
# Cuba 3.0
Requests per second:    3139.86 [#/sec] (mean)
Time per request:       31.849 [ms] (mean)
Time per request:       0.318 [ms] (mean, across all concurrent requests)

# Cuba 2.2.x

Requests per second:    2822.47 [#/sec] (mean)
Time per request:       35.430 [ms] (mean)
Time per request:       0.354 [ms] (mean, across all concurrent requests)

# Sinatra 1.3.2

Requests per second:    1015.26 [#/sec] (mean)
Time per request:       98.497 [ms] (mean)
Time per request:       0.985 [ms] (mean, across all concurrent requests)

# Rails 3.2.1

Requests per second:    242.51 [#/sec] (mean)
Time per request:       412.351 [ms] (mean)
Time per request:       4.124 [ms] (mean, across all concurrent requests)
</pre>

## Other changes worth mentioning

I'll just go over quickly some of the things you might find interesting.

### I. Cuba#root added.

<pre class="prettyprint">
# old
on "" do
  res.write "Home"
end

# new
on root do
  res.write "Home"
end
</pre>

This might seem superficial at first, but `#root`'s main advantage is that
it plays well with app composition by working with or without a trailing
slash. If you want to know more check out the [test case][root].

[root]: https://github.com/soveran/cuba/blob/master/test/root.rb#L42-L82

### II. Internal Cuba::Response object.

Part of the reason why the performance improved was because we replaced
`Rack::Response` in favor of a simpler bare-metal `Cuba::Response` object.

In terms of the actual interface, it's still the same. You still do the
same old stuff: `res.write`, `res.redirect`, and `res.headers`. Cookie
handling is also supported.

### III. Tilt is no longer required by default.

Part of the reason we don't require it by default anymore is because
we've switched to using [mote][mote] for handling the view layer for
all our projects. Of course, we acknowledge that some might still want to
use it, so you can simply require it if necessary.

<pre class="prettyprint">
require "cuba/render"

Cuba.plugin Cuba::Render

Cuba.define do
  on root do
    res.write render("home.erb")
  end
end
</pre>

And that's about it! If you want to know more simply jump in at __#cuba.rb__
in freenode.
