#! /bin/bash

# Description:
#   Server-side git hook that compiles the site whenever new commits are
#   pushed. Here's a rough guide of how to set it up:
#
#       ssh server
#       git --init bare deploy
#       exit
#       git remote add deploy server:~/deploy

[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm

cmd(){
	# Print a diagnostic message and execute a command. Print an error message
	# if it fails.

	echo $1
	${@:2} > /dev/null || (echo "Failed" && exit 1)
}

if ! [ -t 0 ]; then
	read -a ref
fi

IFS='/' read -ra REF <<< "${ref[2]}"
branch="${REF[2]}"

if [ $branch = staging ]; then
	repo_dest=/var/www/staging.sevko.io
else
	repo_dest=/var/www/sevko.io
fi

work_repo_dest=$repo_dest.deploying
cmd "Cloning site." \
	git clone --quiet https://github.com/sevko/sevko.github.io $work_repo_dest
cd $work_repo_dest
unset GIT_DIR

if [ $branch = staging ]; then
	cmd "Checking out staging." git checkout staging 2> /dev/null
fi

cmd "Initializing submodules." git submodule update --init --quiet
cmd "Compiling resume." json_resume convert \
	--template=_resume/resume.mustache.tex --out=tex_pdf _resume/resume.yaml
cmd "Compiling site." jekyll build

cd ..
cmd "Removing old site." rm -rf $repo_dest
cmd "Moving new site." mv $work_repo_dest $repo_dest
cmd "Restarting nginx." service nginx restart
echo "Build completed."
