class FileModel
  FORMATS = [:mdown, :haml, :textile]
  @@cache = {}
  
  attr_reader :filename, :mtime, :metadata

  def self.model_path(basename = nil)
    Nesta::Config.content_path(basename)
  end
  
  def self.find_all
    file_pattern = File.join(model_path, "**", "*.{#{FORMATS.join(',')}}")
    Dir.glob(file_pattern).map do |path|
      relative = path.sub("#{model_path}/", "")
      load(relative.sub(/\.(#{FORMATS.join('|')})/, ""))
    end
  end
  
  def self.needs_loading?(path, filename)
    @@cache[path].nil? || File.mtime(filename) > @@cache[path].mtime
  end
  
  def self.load(path)
    FORMATS.each do |format|
      filename = model_path("#{path}.#{format}")
      if File.exist?(filename) && needs_loading?(path, filename)
        @@cache[path] = self.new(filename)
        break
      end
    end
    @@cache[path]
  end
  
  def self.purge_cache
    @@cache = {}
  end
  
  def initialize(filename)
    @filename = filename
    @format = filename.split(".").last.to_sym
    parse_file
    @mtime = File.mtime(filename)
  end

  def permalink
    File.basename(@filename, ".*")
  end

  def path
    abspath.sub(/^\//, "")
  end
  
  def abspath
    prefix = File.dirname(@filename).sub(Nesta::Config.page_path, "")
    File.join(prefix, permalink)
  end
  
  def to_html
    case @format
    when :mdown, :markdown, :md
      RDiscount.new(markup).to_html
    when :haml
      Haml::Engine.new(markup).to_html
    when :textile
      RedCloth.new(markup).to_html
    end
  end
  
  def last_modified
    @last_modified ||= File.stat(@filename).mtime
  end
  
  def description
    metadata.description
  end
  
  def keywords
    metadata.keywords
  end

  private
    def markup
      @markup
    end
    
    def paragraph_is_metadata(text)
      text.split("\n").first =~ /^[\w ]+:/
    end
    
    def parse_file
      first_para, remaining = File.open(@filename).read.split(/\r?\n\r?\n/, 2)
      @metadata = Hashie::Mash.new
      if paragraph_is_metadata(first_para)
        @markup = remaining
        for line in first_para.split("\n") do
          key, value = line.split(/\s*:\s*/, 2)
          @metadata[key.downcase] = value.chomp
        end
      else
        @markup = [first_para, remaining].join("\n\n")
      end
    rescue Errno::ENOENT  # file not found
      raise Sinatra::NotFound
    end
end
