SHELL=/bin/bash
MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CODE = $(abspath $(MAKEFILEDIR)/..)

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma $(1)"")
uri = $(shell echo file:///$(call win_path,$(1))  | perl -pe 's/ /%20/g')
unix_paths = $(shell cygpath -u -f $(1)"")
else
win_path = $(shell readlink -f $(1)"")
uri = $(shell echo file:$(abspath $(1)) | perl -pe 's/ /%20/g')
unix_paths = $(1)
endif

# The following variables should be set in local_defs.mk:

EMAIL=crossref@acme.com
USER=user
PASS=pass
CROSSREFTMP=~/crossref

-include $(MAKEFILEDIR)/local_defs.mk

export

# Unfortunately, there will be some warnings because secondary
# expansion will treat the function definitions as plain variables.
# You can ignore warnings like the following:
# cygpath: No such file or directory
# cygpath: can't convert empty path

.SECONDEXPANSION:

# This target will issue a crossref request
%.qb.xml: $$(subst crossref,hobots,$$(subst .qb,,$$@))
	-mkdir $(dir $@)
	$(CODE)/calabash/calabash.sh \
		-i source=$(call uri,$<) \
		-o qb=$(call win_path,$@) \
		$(call uri,$(MAKEFILEDIR)/xpl/jats-submit-crossref-query.xpl) \
		user=$(CROSSREFUSER) pass=$(CROSSREFPASS) \
		email=$(EMAIL)

# This target should be invoked periodically.
# See README.txt for preparation instructions
fetchmail:
	fetchmail -f $(CODE)/crossref/infrastructure/fetchmailrc
	$(CODE)/calabash/calabash.sh \
		-i merging-stylesheet=$(call uri,$(MAKEFILEDIR)/xsl/merge-results-with-query.xsl) \
		-i conf=$(call uri,$(CODE)/conf/hogrefe_conf.xml) \
		-o result=$(call win_path,$(CROSSREFTMP))/files.txt \
		$(call uri,$(MAKEFILEDIR)/xpl/process-crossref-results.xpl) \
		input-dir-uri=$(call uri,$(CROSSREFTMP))
	-svn add --depth empty $(abspath $(addsuffix ..,$(dir $(call unix_paths,$(CROSSREFTMP)/files.txt))))
	-svn add --depth empty $(dir $(call unix_paths,$(CROSSREFTMP)/files.txt))
	-svn add $(call unix_paths,$(CROSSREFTMP)/files.txt)
	-svn add $(addsuffix .jsx,$(basename $(call unix_paths,$(CROSSREFTMP)/files.txt)))
	-svn ci --depth empty $(abspath $(addsuffix ..,$(dir $(call unix_paths,$(CROSSREFTMP)/files.txt)))) -m automatic
	-svn ci --depth empty $(dir $(call unix_paths,$(CROSSREFTMP)/files.txt)) -m automatic
	svn ci $(call unix_paths,$(CROSSREFTMP)/files.txt) -m automatic
	svn ci $(addsuffix .jsx,$(basename $(call unix_paths,$(CROSSREFTMP)/files.txt))) -m automatic
	-rm $(CROSSREFTMP)/*
