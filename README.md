# sevko.io

My personal portfolio site and blog, powered by [Jekyll](http://jekyllrb.com/). Live at: [sevko.io](http://sevko.io/);
feel free to subscribe to my [RSS feed](http://sevko.io/articles/feed.xml)!

## installation

```
bundle install
git submodule update --init
jekyll build
```

My server of choice is nginx since it's well-suited for static files. All of the necessary configuration is inside
`nginx.conf`. Also, see `post-receive.sh` for the server-side Git hook that I use to automatically build the site.
