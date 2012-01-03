module DB
  def self.articles
    YAML.load_file(root("settings", "articles.yml"))
  end

  def self.projects
    YAML.load_file(root("settings", "projects.yml"))
  end

  def self.screencasts
    YAML.load_file(root("settings", "screencasts.yml"))
  end
end