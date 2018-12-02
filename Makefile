# Makefile to generate files

# Variables
__VERSION           := 1.1
BASEURL             := https://st.argp.in/pandoc
# GOOGLE_VERIFICATION :=

# Directories
SOURCE      := source
TEMPL       := template
HTML        := html
STATIC      := static
FOLDERS     := $(subst $(SOURCE),$(HTML),$(shell find $(SOURCE) -type d))

# Files
MD_FILES     := $(shell find $(SOURCE) -type f -name "*.md")
HTML_FILES   := $(subst $(SOURCE),$(HTML),$(patsubst %.md,%.html,$(MD_FILES)))
HTML_TEMPL   := $(wildcard $(TEMPL)/*.html)
STATIC_FILES := $(subst $(STATIC),$(HTML),$(wildcard $(STATIC)/*))
SITEMAP      := $(HTML)/sitemap.txt
TREE         := $(HTML)/sitemap.html

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
			--strip-comments \
			--variable google_verification=$(GOOGLE_VERIFICATION)

# Default target
all: $(FOLDERS) $(HTML_FILES) $(STATIC_FILES) $(TREE) $(SITEMAP)

# Create folders
$(FOLDERS):
	mkdir -p $@

# HTML Files
$(HTML_FILES): $(HTML_TEMPL)

html/%.html: source/%.md
	$(PANDOC) $(HTML_FLAGS) --output $@ $<

# Static Assets
$(STATIC_FILES): $(wildcard $(STATIC)/*)
	cp -r $(STATIC)/* $(HTML)

# Sitemap
$(SITEMAP): $(HTML_FILES)
	find $(HTML)/ \
		-name "*.html" \
		! -name "404.html" \
		-type f \
		-printf "$(BASEURL)/%P\n" > $@

# Tree
$(TREE): $(HTML_FILES)
	touch $@ && \
	tree \
		$(HTML) \
		-P '*.html|*.css|*.txt' \
		--dirsfirst \
		-H $(BASEURL) \
		-T "Sitemap" \
		-o $@

# Clean
clean:
	rm -rf $(HTML)/*

# Server
server:
	caddy -host 0.0.0.0 -port 8000 -root html/

# PHONY targets
.PHONY: all clean server
