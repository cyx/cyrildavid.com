class Project
  attr :title
  attr :description
  attr :url

  def initialize(atts)
    @title = atts[:title]
    @description = atts[:description]
    @url = atts[:url]
  end

  def self.all
    DB.projects.map { |atts| new(atts) }
  end
end
