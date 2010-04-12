PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include(RspecHpricotMatchers)
  conf.include(Nesta)
end

def app
  ##
  # You can hanlde all padrino applications using instead:
  #   Padrino.application
  Presto.tap { |app|  }
end


# set :views => File.join(File.dirname(__FILE__), "..", "views"),
#     :public => File.join(File.dirname(__FILE__), "..", "public")
# 
# set :environment, :test
# set :reload_templates, true

#require File.join(File.dirname(__FILE__), "..", "app")

module RequestSpecHelper
  # def app
  #   Sinatra::Application
  # end
  # 
  def body
    last_response.body
  end
end
