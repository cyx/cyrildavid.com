require_relative "shotgun"
require_relative "lib/db"
require_relative "lib/article"
require_relative "lib/project"
require_relative "lib/screencast"
require_relative "lib/helpers"

Cuba.plugin Cuba::Helpers

Cuba.use Rack::Static,
  root: root("public"),
  urls: ["/scripts", "/less", "/css"]

Cuba.plugin Cuba::Mote

Cuba.define do
  on "" do
    res.write view("home", title: "Cyril David", id: "home")
  end
  
  on "articles/:y/:m/:d/:slug" do |_, _ ,_, slug|
    article = Article[slug]

    res.write view("article", title: article.title, 
                              article: article, 
                              id: "articles")
  end

  on "articles" do
    res.write view("articles", title: "Articles", 
                               articles: Article.all, 
                               id: "articles")
  end
  
  on "screencasts" do
    res.write view("casts", title: "Screen Casts", 
                            screencasts: ScreenCast.all, 
                            id: "screencasts")
  end

  on "projects" do
    res.write view("projects", title: "Projects", 
                               id: "projects",
                               projects: Project.all)
  end
end
