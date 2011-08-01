require 'open-uri'
require 'digest/md5'
require 'uri'

module IncludesPacker

	def package_valid?
	  params[:host] && params[:include]		
	end

	def package_etag
	  etag Digest::MD5.hexdigest("#{params[:host]}:#{params[:include]}:#{params[:version]}")
	end

	def pack(base_url, scripts)
	  begin
	    target_url = ''
	    scripts.each { |s| target_url = URI.join(base_url, s).to_s; yield(s, open(target_url).read) }

	  rescue OpenURI::HTTPError => ex
	    raise "Error: <#{target_url}> is invalid."
	  rescue Exception => ex
	    raise "Error: make sure host and includes are valid.#{ex}#{ex.inspect}"
	  end
	end
end
