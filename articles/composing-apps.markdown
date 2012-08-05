Modularity is probably one of the most important properties of
maintainable software. [Quoting from Wikipedia][modularity]:

<blockquote>Modularity 
is a logical partitioning of the "software design" 
that allows complex software to be manageable for the purpose 
of implementation and maintenance. The logic of partitioning 
may be based on related functions, implementation considerations, 
data links, or other criteria.
</blockquote>

[modularity]: http://en.wikipedia.org/wiki/Modularity#In_software_designing

Personally, it's all about managing complexity. If it was left
to computers, they couldn't care less if an OS was written in
one `main` function. But we humans, work best when thinking about
separate parts of a bigger whole.

## Real world example please

Ok now that the philosophical part is out of the way, let's take
the most basic example of modularity in a web app.

For the sake of argument, Let's say that we want to put up
a support website for a commercial product. We would need the
following:

1. A Blog (for hype generation purposes :-)
2. A support tracking system
3. Documentation

Assuming we have **foobarbaz.com** for the domian, we will have
the following URL endpoints:

- http://foobarbaz.com/blog
- http://foobarbaz.com/support
- http://foobarbaz.com/docs

Now let us pretend that we want to specifically write all 
of this in one Rack app. How do we go about doing this?

We'll make use of the Rack::Builder method called `map`. 

<pre class="prettyprint">
# config.ru

require File.expand_path("site", File.dirname(__FILE__))

map "/blog" do
  run Blog
end

map "/support" do
  run Support
end

map "/docs" do
  run Docs
end
</pre>

Pretty simple and elegant looking right? Just a few things you
need to be aware of:

1. The path you pass to map needs to have a prefixed slash.
2. The app is exactly the same as a standard rack app. It should
   respond to a `call` method and should respond with a rack tuple.
3. The `PATH_INFO` is adjusted within the context of the mounted app.
   So if you go to `/support/submit`, the `PATH_INFO` will simply be
   `/submit`.

We'll make use of our pet project `Frank` which was discussed in the
previous article, [Understanding Rack][understanding].

[understanding]: http://cyrildavid.com/articles/2012/01/03/understanding-rack

<pre class="prettyprint">
# site.rb

require File.expand_path("../helloworld/frank", File.dirname(__FILE__))

class Blog < Frank
  get "/" do
    "Main Blog"
  end

  get "/post/:id" do |id|
    "Displaying post #{id}"
  end
end

class Support < Frank
  get "/" do
    "Main Support Site"
  end

  get "/submit" do
    "&lt;form method='post'&gt;&lt;textarea name='issue'&gt;&lt;/textarea&gt;" +
    "&lt;input type='submit' name='submit value='Help'&gt;&lt;/form&gt;"
  end

  post "/submit" do
    "Received issue: %s" % request.params["issue"]
  end
end

class Docs < Frank
  get "/" do
    "We're here to help!"
  end

  get "/download" do
    "Download our documentation in PDF or read it online!"
  end
end
</pre>

## Play by play

So what just happened? If you noticed, the apps are matching
against URLs as if they were on the root of the domain.

The reason for this is that when Rack maps a sub app, it mutates
two environment variables, namely `SCRIPT_NAME` and `PATH_INFO`.

The following realtime state should illustrate what I'm trying to say.

<table class="bordered-table">
<tr>
<td>1. We receive the request /docs/download.</td>
<td><b>SCRIPT_NAME</b>="", <b>PATH_INFO</b>=/docs/download</td>
</tr>

<tr>
<td>2. Rack intercepts /docs and transfers control to the sub app.</td>
<td><b>SCRIPT_NAME</b>="/docs", <b>PATH_INFO</b>=/download</td>
</tr>

<tr>
<td>3. Our app parses against <b>PATH_INFO.</b></td>
<td><b>SCRIPT_NAME</b>="/docs", <b>PATH_INFO</b>=/download</td>
</tr>
</table>

Also, see the [actual source code][rack-script-name] for more details:

[rack-script-name]: https://github.com/rack/rack/blob/master/lib/rack/urlmap.rb#L61-L62

You might be wondering though, how about redirects? How should
the app know what the actual full `PATH_INFO` should be?

Luckily Rack has thought of that for us. If we're using `Rack::Request`, 
(which most of us do), then accessing `Rack::Request#path` will 
[yield the concatenation][concat] of `SCRIPT_NAME` and `PATH_INFO`.

If you must access the original values, you can through their 
respective accessors, namely `path_info` and `script_name`.

[concat]: https://github.com/rack/rack/blob/master/lib/rack/request.rb#L292-L294
