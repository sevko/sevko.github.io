# Custom tag intended to be used within blog posts to convert a file path to
# the full resource URL. Infer's the blog post's resource directory name from
# its title.

module Jekyll
	class StaticFilePath < Liquid::Tag

		def initialize(tag_name, path, tokens)
			super
			@path = path
		end

		def render(context)
			files_url = context.registers[:site].config['files_url']
			post_title = context.environments.first['page']['title']
			post_dir_path = post_title.gsub(/[^a-zA-Z0-9]/, '_')
			"#{files_url}/#{post_dir_path}/#{@path}"
		end
	end
end

Liquid::Template.register_tag('static', Jekyll::StaticFilePath)
