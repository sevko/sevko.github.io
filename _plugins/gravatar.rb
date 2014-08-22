# A Liquid filter to generate the MD5 hash of an input string, for Gravatar
# image retrieval.

require "digest/md5"

module Jekyll
	module GravatarFilter
		def gravatar(input)
			email_address = input.downcase.strip
			hash = Digest::MD5.hexdigest(email_address)
			"http://www.gravatar.com/avatar/#{hash}"
		end
	end
end

Liquid::Template.register_filter(Jekyll::GravatarFilter)
