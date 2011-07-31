require 'sinatra'
require 'uglifier'
require 'sinatra/reloader' if development?
require 'lib/includes_packer'

include IncludesPacker

UF = Uglifier.new

class PackJS < Sinatra::Base
  get '/' do
    content_type 'text/javascript', :charset => 'utf-8'
    return "" unless package_valid?
  
    package_etag

    pack(params[:host],params[:include].split(',')) { |text| UF.compile(text.force_encoding('UTF-8')) }
  end
end


