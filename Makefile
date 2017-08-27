install:
	bundle install
	git submodule update --init
	sudo apt-get install texlive texlive-latex-extra texlive-fonts-extra

build: site resume.pdf

site:
	jekyll build

resume.pdf: _resume/resume.mustache.tex _resume/resume.yaml
	json_resume convert --template=_resume/resume.mustache.tex \
		--out=tex_pdf _resume/resume.yaml

publish: build
	# Upload the compiled website to S3.
	#
	# Since Jekyll doesn't fully support incremental builds (where only
	# modified files get recompiled), lots of files in _site/ end up getting
	# re-compiled even if they don't change; to avoid uploading these to S3,
	# rsync _site/ against a persistent _s3_site/ directory using file
	# checksums rather than timestamps, and then sync *that* with S3. This
	# ensures that only files whose contents have changed get uploaded.

	print_msg(){
		echo "$(tput bold)$1$(tput sgr0)"
	}

	print_msg "rsyncing..."
	rsync -ivac --no-t --delete _site/ _s3_site/
	echo ""

	print_msg "The following files will be synced:"
	aws s3 sync --dryrun _s3_site s3://sevko.io
	echo ""

	while true; do
		read -p "$(tput bold)Does that look right? (y/n) $(tput sgr0)" yn
		case $yn in
			[y]* ) aws s3 sync _s3_site s3://sevko.io; break;;
			[n]* ) print_msg "Cancelling"; break;;
			* ) print_msg "Enter y or n";;
		esac
	done

serve:
	jekyll serve

.PHONY: build serve publish
