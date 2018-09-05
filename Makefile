# Makefile to generate HTML pages

# Directories
SOURCE   = source
TEMPL    = template
OUTPUT   = html
FOLDERS  = $(subst $(SOURCE),$(OUTPUT),$(shell find $(SOURCE) -type d))

# Files
MD_FILES    = $(shell find $(SOURCE) -type f -name "*.md")
HTML_FILES  = $(subst $(SOURCE),$(OUTPUT),$(patsubst %.md,%.html,$(MD_FILES)))
CSS_FILES   = $(subst $(TEMPL),$(OUTPUT),$(wildcard $(TEMPL)/*.css))
TEMPL_FILES = $(wildcard $(TEMPL)/*.html)

# Parser options
PANDOC = pandoc
FLAGS  = \
		--standalone \
		--from markdown \
		--to html \
		--template $(TEMPL)/default.html \
		--mathjax \
		--include-after-body=$(TEMPL)/footer.html \
		--include-before-body=$(TEMPL)/navigation.html \
		--strip-comments

# Default target to generate all files
.PHONY: all
all: $(FOLDERS) $(HTML_FILES) $(CSS_FILES)

# Generate all HTML files when Template files change
$(HTML_FILES): $(TEMPL_FILES)

# Create sub directories automatically
$(FOLDERS):
	mkdir -p $@

# Target for all HTML files
html/%.html: source/%.md
	$(PANDOC) $(FLAGS) --output $@ $<

# Copy CSS files
html/%.css: template/%.css
	cp $< $@

# Target to clean output folder
.PHONY: clean
clean:
	rm -rf $(OUTPUT)/*

# Start web server locally for testing
.PHONY: server
server:
	caddy -host 0.0.0.0 -port 8000 -root html/
