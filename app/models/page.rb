class Page < FileModel
  module ClassMethods
    def model_path(basename = nil)
      Nesta::Config.page_path(basename)
    end
    
    def find_by_path(path)
      load(path)
    end

    def find_articles
      find_all.select { |page| page.date }.sort { |x, y| y.date <=> x.date }
    end
    
    def menu_items
      menu = Nesta::Config.content_path("menu.txt")
      pages = []
      if File.exist?(menu)
        File.open(menu).each { |line| pages << Page.load(line.chomp) }
      end
      pages
    end
  end

  extend ClassMethods
  
  def ==(other)
    self.path == other.path
  end
  
  def heading
    regex = case @format
      when :mdown
        /^#\s*(.*)/
      when :haml
        /^\s*%h1\s+(.*)/
      when :textile
        /^\s*h1\.\s+(.*)/
      end
    markup =~ regex
    Regexp.last_match(1)
  end
  
  def date(format = nil)
    @date ||= if metadata("date")
      if format == :xmlschema
        Time.parse(metadata("date")).xmlschema
      else
        DateTime.parse(metadata("date"))
      end
    end
  end
  
  def atom_id
    metadata("atom id")
  end
  
  def read_more
    metadata("read more") || "Continue reading"
  end
  
  def title
    if self.respond_to?(:parent) && self.parent
      "#{self.heading} - #{self.parent.heading}"
    else
     "#{self.heading} - #{Nesta::Config.title}"
    end
  end
  
  def summary
    if summary_text = metadata("summary")
      summary_text.gsub!('\n', "\n")
      case @format
      when :textile
        RedCloth.new(summary_text).to_html
      else
        RDiscount.new(summary_text).to_html
      end
    end
  end
  
  def body
    case @format
    when :mdown, :markdown, :md
      body_text = markup.sub(/^#[^#].*$\r?\n(\r?\n)?/, "")
      RDiscount.new(body_text).to_html
    when :haml
      body_text = markup.sub(/^\s*%h1\s+.*$\r?\n(\r?\n)?/, "")
      Haml::Engine.new(body_text).render
    when :textile
      body_text = markup.sub(/^\s*h1\.\s+.*$\r?\n(\r?\n)?/, "")
      RedCloth.new(body_text).to_html
    end
  end
  
  def categories
    categories = metadata("categories")
    paths = categories.nil? ? [] : categories.split(",").map { |p| p.strip }
    valid_paths(paths).map { |p| Page.find_by_path(p) }.sort do |x, y|
      x.heading.downcase <=> y.heading.downcase
    end
  end
  
  def parent
    Page.load(File.dirname(path))
  end
  
  def pages
    Page.find_all.select do |page|
      page.date.nil? && page.categories.include?(self)
    end.sort do |x, y|
      x.heading.downcase <=> y.heading.downcase
    end
  end
  
  def articles
    Page.find_articles.select { |article| article.categories.include?(self) }
  end
  
  private
    def valid_paths(paths)
      paths.select do |path|
        FORMATS.detect do |format|
          File.exist?(
              File.join(Nesta::Config.page_path, "#{path}.#{format}"))
        end
      end
    end
end
