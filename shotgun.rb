module Kernel
  ROOT = File.expand_path(File.dirname(__FILE__))

private
  def root(*args)
    File.join(ROOT, *args)
  end

  def app
    $_app ||= YAML.load_file(root("settings/app.yml"))
  end
end

require "bluecloth"
require "cuba"
require "cuba/contrib"
require "yaml"
