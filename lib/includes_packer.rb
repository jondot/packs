require 'open-uri'
require 'digest/md5'

module IncludesPacker

	def package_valid?
	  params[:host] && params[:include]		
	end

	def package_etag
	  etag Digest::MD5.hexdigest("#{params[:host]}:#{params[:include]}:#{params[:version]}")
	end

	def pack(base_url, scripts)
	  begin
	    text = ''; target_url = ''
	    scripts.each { |s| target_url = base_url + s; text << open(target_url).read; }

	    yield(text)

	  rescue OpenURI::HTTPError => ex
	    return "Error: <#{target_url}> is invalid."
	  rescue Exception => ex
	    return "Error: make sure host and includes are valid.#{ex}#{ex.inspect}"
	  end
	end
end
