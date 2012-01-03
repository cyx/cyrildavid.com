class Project
  attr :title
  attr :description

  def initialize(atts)
    @title = atts[:title]
    @description = atts[:description]
  end

  def self.all
    DB.projects.map { |atts| new(atts) }
  end
end