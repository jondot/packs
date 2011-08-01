require 'sinatra'
require 'uglifier'
require 'sinatra/reloader' if development?
require 'lib/includes_packer'
require 'coffee_script'





UF = Uglifier.new

#
# pack javascript
# http://localhost:9292/?host=http://p.mnmly.com/&include=file-api/src/coffee/script.coffee,js/handlebars-0.9.0.pre.5.js
#
class PackJS < Sinatra::Base
  
  include IncludesPacker

  get '/' do
    content_type 'text/javascript', :charset => 'utf-8'
    return "" unless package_valid?

    package_etag

    result = ''
    pack(params[:host],params[:include].split(',')) do  |file, text| 
      ops = []
      ops << ->(text) { text.force_encoding('UTF-8') }
      ops << ->(text) { CoffeeScript.compile(text) } if file.end_with? '.coffee' 
      ops << ->(text) { UF.compile(text) }
      result << ops.inject(text){|o,proc| proc.call(o)}
    end
    result
  end

  error do
    env['sinatra.error']
  end
end


