# Makefile of _Dictionarium de Interlingue_

# By Marcos Cruz (programandala.net)
# http://ne.alinome.net

# Last modified 201910271639
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-pdf
# - dbtoepub
# - dictfmt
# - gforth 
# - pandoc
# - vim
# - xsltproc

# ==============================================================
# Config

VPATH=./src:./target

book_basename=dictionarium_de_interlingue
title="Dictionarium de Interlingue"
book_author=""
publisher="ne.alinome"
description=

dict_basename=$(book_basename)
dict_data_url=http://ne.alinome.net
dict_data_format=c5

# ==============================================================
# Interface

.PHONY: all
all: epub pdf

.PHONY: epub
epub: epubd epubp epubx

.PHONY: epubd
epubd: target/$(book_basename).adoc.xml.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book_basename).adoc.xml.pandoc.epub

.PHONY: epubx
epubx: target/$(book_basename).adoc.xml.xsltproc.epub

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: target/$(book_basename).adoc.a4.pdf

.PHONY: pdfletter
pdfletter: target/$(book_basename).adoc.letter.pdf

.PHONY: $(dict_data_format)
$(dict_data_format): tmp/$(dict_basename).$(dict_data_format)

.PHONY: dict
dict: target/$(dict_basename).dict.dz

.PHONY: mdf
mdf: target/$(book_basename).mdf

.PHONY: clean
clean:
	rm -f target/* tmp/*

# ==============================================================
# Convert source data files to an intermediate format

# The intermediate format makes the data easier to be interpreted
# as a Forth program.

tmp/%.txt: src/%.txt
	sed "s@^ *@term{ @" $< | \
	sed "s@ *# *@} $(basename $(notdir $<)){ @" | \
	sed "s@ *#.*@}@" \
	> $@

tmp/all.txt: tmp/cs.txt tmp/de.txt tmp/eo.txt
	sort -f $^ > $@

# ==============================================================
# Convert the intermediate format to MDF

# The MDF format is used by several dictionary programs created by SIL
# (http://sil.org), e.g. Lexique Pro and Toolbox.

target/$(book_basename).mdf: tmp/all.txt
	gforth make/mdf.fs $< -e bye > $@

# ==============================================================
# Convert Asciidoctor to PDF

target/%.adoc.a4.pdf: src/%.adoc
	asciidoctor-pdf \
		--out-file=$@ $<

target/%.adoc.letter.pdf: src/%.adoc
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to DocBook

.SECONDARY: tmp/$(book_basename).adoc.xml

tmp/%.adoc.xml: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert DocBook to EPUB

# ------------------------------------------------
# With dbtoepub

target/$(book_basename).adoc.xml.dbtoepub.epub: \
	tmp/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

target/$(book_basename).adoc.xml.pandoc.epub: \
	tmp/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
	src/pandoc_epub_template.txt \
	src/pandoc_epub_stylesheet.css
	pandoc \
		--from docbook \
		--to epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/pandoc_epub_stylesheet.css \
		--variable=lang:$(lang) \
		--variable=autor:$(book_author) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ------------------------------------------------
# With xsltproc

target/%.adoc.xml.xsltproc.epub: tmp/%.adoc.xml
	rm -fr tmp/xsltproc/* && \
	xsltproc \
		--output tmp/xsltproc/ \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/epub/docbook.xsl \
		$< && \
	echo -n application/epub+zip > tmp/xsltproc/mimetype && \
	cd tmp/xsltproc/ && \
	zip -0 -X ../../$@.zip mimetype && \
	zip -rg9 ../../$@.zip META-INF && \
	zip -rg9 ../../$@.zip OEBPS && \
	cd - && \
	mv $@.zip $@

# XXX TODO -- Find out how to pass parameters and their names, from the XLS:
#    --param epub.ncx.filename testing.ncx \

# XXX TODO -- Add the stylesheet. The XLS must be modified first,
# or the resulting XHTML must be modified at the end.
#  cp -f src/xsltproc/stylesheet.css tmp/xsltproc/OEBPS/ && \

# ==============================================================
# Convert DocBook to OpenDocument

target/$(book_basename).adoc.xml.pandoc.odt: \
	tmp/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
	src/pandoc_odt_template.txt
	pandoc \
		--from docbook \
		--to odt \
		--template=src/pandoc_odt_template.txt \
		--variable=lang:$(lang) \
		--variable=autor:$(book_author) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description) \
		--output $@ $<

# ==============================================================
# Convert the original data file to "dict_data_format"

.SECONDARY: tmp/$(dict_basename).$(dict_data_format)

# XXX REMARK -- Example:
tmp/%.$(dict_data_format): src/%.txt
	gforth make/convert_data.fs -e "run $< bye" > $@
	vim -e -S make/tidy_data.vim $@

# ==============================================================
# Convert dictionary data to dict format

target/%.dict: tmp/%.$(dict_data_format)
	dictfmt \
		--utf8 \
		-u $(dict_data_url) \
		-s $(description) \
		-$(dict_data_format) $(basename $@) \
		< $<

# ==============================================================
# Install and uninstall dict

%.dict.dz: %.dict
	dictzip --force $<

.PHONY: install
install: target/$(dict_basename).dict.dz
	cp --force \
		$< \
		$(addsuffix .index, $(basename $(basename $^))) \
		/usr/share/dictd/
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

.PHONY: uninstall
uninstall:
	rm --force /usr/share/dictd/$(dict_basename).*
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

# ==============================================================
# Change log

# 2019-08-14: Start.
#
# 2019-08-16: Create draft rules for creating the MDF file from the sources.
#
# 2019-10-26: Add note about the MDF format.
#
# 2019-10-27: Add the Czech source. Create the MDF target with Gforth instead
# of Vim. Simplify the sorting of the intermediate file.
