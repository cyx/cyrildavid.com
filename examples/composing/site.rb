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
    "<form method='post'><textarea name='issue'></textarea>" +
    "<input type='submit' name='submit value='Help'></form>"
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
