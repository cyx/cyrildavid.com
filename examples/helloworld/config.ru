# app = lambda { |env|
#   [200, { "Content-Type" => "text/plain" }, ["Hello World"]]
# }
#
# class Hello
#   def self.call(env)
#     case env["PATH_INFO"]
#     when "/"
#       [200, { "Content-Type" => "text/plain" }, ["Hello World"]]
#     when "/datetime"
#       [200, { "Content-Type" => "text/plain" }, [Time.now.rfc2822]]
#     else
#       [404, { "Content-Type" => "text/plain" }, ["Fail Whale"]]
#     end
#   end
# end

# class Hello
#   def self.call(env)
#     req = Rack::Request.new(env)
#     res = Rack::Response.new
#
#     case req.path
#     when "/"
#       res.write "Hello World"
#     when "/datetime"
#       res.write Time.now.rfc2822
#     else
#       res.status = 404
#       res.write "404 Not Found"
#     end
#
#     res.finish
#   end
# end

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