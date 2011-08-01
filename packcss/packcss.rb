require 'sinatra'
require 'sinatra/reloader' if development?
require 'lib/includes_packer'
require 'rainpress'
require 'sass'



#
# Pack CSS
# http://localhost:9292/?host=http://technocrat.net&include=/stylesheets/standard1.sass,/stylesheets/kai.css
#
class PackCSS < Sinatra::Base

  include IncludesPacker

  get '/' do
    content_type 'text/stylesheet', :charset => 'utf-8'
    return "" unless package_valid?
  
    package_etag
  
    result = ''
    pack(params[:host],params[:include].split(',')) do  |file, text| 
      ops = []
      ops << ->(text) { text.force_encoding('UTF-8') }
      ops << ->(text) { Sass::Engine.new(text, :syntax => :sass).render } if file.end_with? '.sass'
      ops << ->(text) { Sass::Engine.new(text, :syntax => :scss).render } if file.end_with? '.scss'
      ops << ->(text) { Rainpress.compress(text) } 
      result << ops.inject(text){|o,proc| proc.call(o)}
    end
    result
  end

  error do
    env['sinatra.error']
  end
end
