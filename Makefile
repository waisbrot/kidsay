.PHONY: init serve post help

JK := bundle exec jekyll

# trick to get a space for replacement
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

# special handling for the "post" target
ifeq (post,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

help:
	@echo 'init		initialize the repository'
	@echo 'serve		build and serve the site locally'
	@echo 'post <title>	make a new post and print the name of the created file'
	@echo 'help		print this'

init: _config.yml .git

serve: index.html
	$(JK) serve

post: _posts
	@if [ -z "$(RUN_ARGS)" ]; then \
		echo "make post: must supply a title" >&2; \
		exit 1; \
	fi
	$(eval SHORT_DATE := $(shell date "+%Y-%m-%d"))
	$(eval LONG_DATE := $(shell date "+%Y-%m-%d %T %z"))
	$(eval FILE := _posts/${SHORT_DATE}-$(subst $(SPACE),-,$(RUN_ARGS)).md)
	set -o noclobber && echo ---\\nlayout: post\\ntitle:  "${RUN_ARGS}"\\ndate:   ${LONG_DATE}\\ncategories:\\ntags:\\n---\\n > ${FILE}
	@echo ${FILE}


_posts:
	mkdir _posts

_config.yml:
	bundle exec jekyll new . --force
