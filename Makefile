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
	bash publish.sh

serve:
	jekyll serve

.PHONY: build serve publish
