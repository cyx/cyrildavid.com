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
