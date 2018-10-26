# Makefile to generate files

# SEO Variables
BASEURL := https://st.argp.in/pandoc

# Directories
SOURCE      := source
TEMPL       := template
HTML        := html
FOLDERS     := $(subst $(SOURCE),$(HTML),$(shell find $(SOURCE) -type d))

# Files
MD_FILES    := $(shell find $(SOURCE) -type f -name "*.md")
HTML_FILES  := $(subst $(SOURCE),$(HTML),$(patsubst %.md,%.html,$(MD_FILES)))
CSS_FILES   := $(subst $(TEMPL),$(HTML),$(wildcard $(TEMPL)/*.css))
HTML_TEMPL  := $(wildcard $(TEMPL)/*.html)
SITEMAP     := $(HTML)/sitemap.txt

# Parser options
PANDOC      := pandoc
HTML_FLAGS  := \
			--standalone \
			--from markdown \
			--to html \
			--template $(TEMPL)/default.html \
			--mathjax \
			--include-after-body=$(TEMPL)/footer.html \
			--include-before-body=$(TEMPL)/navigation.html \
			--strip-comments

# Default target
all: $(FOLDERS) $(HTML_FILES) $(CSS_FILES) $(SITEMAP)

# Create folders
$(FOLDERS):
	mkdir -p $@

# HTML Files
$(HTML_FILES): $(HTML_TEMPL)

html/%.html: source/%.md
	$(PANDOC) $(HTML_FLAGS) --output $@ $<

html/%.css: template/%.css
	cp $< $@

# Sitemap
$(SITEMAP): $(HTML_FILES)
	find $(HTML)/ -name "*.html" -type f -printf "$(BASEURL)/%P\n" > $@

# Clean
clean:
	rm -rf $(HTML)/*

# Server
server:
	caddy -host 0.0.0.0 -port 8000 -root html/

# PHONY targets
.PHONY: all clean server
