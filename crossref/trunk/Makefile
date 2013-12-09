SHELL=/bin/bash
MAKEFILEDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CODE = $(abspath $(MAKEFILEDIR)/..)

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma $(1))
uri = $(shell echo file:///$(call win_path,$(1))  | perl -pe 's/ /%20/g')
unix_paths = $(shell cygpath -u -f $(1))
else
win_path = $(abspath $(1))
uri = $(shell echo file:$(abspath $(1)) | perl -pe 's/ /%20/g')
unix_paths = $(shell cat $(abspath $(1)))
endif

ACTIONLOG = /dev/null

# The following variables should be set in local_defs.mk:

EMAIL=crossref@acme.com
USER=user
PASS=pass
CROSSREFTMP=~/crossref
FETCHMAIL=fetchmail

-include $(MAKEFILEDIR)/local_defs.mk

export
unexport win_path uri unix_paths


testi:
#	$(FETCHMAIL) -f $(CODE)/crossref/infrastructure/fetchmailrc
	$(CODE)/calabash/calabash.sh \
		-i merging-stylesheet=$(call uri,$(MAKEFILEDIR)/xsl/merge-results-with-query.xsl) \
		-i conf=$(call uri,$(CODE)/conf/hogrefe_conf.xml) \
		-o result=$(call win_path,$(CROSSREFTMP))/files.txt \
		$(call uri,$(MAKEFILEDIR)/xpl/process-crossref-results.xpl) \
		input-dir-uri=$(call uri,$(CROSSREFTMP)) \
		tmp-suffix=".tmp"
	ls -l $(CROSSREFTMP)
	cat $(CROSSREFTMP)/files.txt
	echo
	echo $(call unix_paths,$(CROSSREFTMP)/files.txt)


# This target should be invoked periodically.
# See README.txt for preparation instructions
%/files.txt:
	$(FETCHMAIL) -f $(CODE)/crossref/infrastructure/fetchmailrc || [ $$? -eq 1 ]
	$(CODE)/calabash/calabash.sh \
		-i merging-stylesheet=$(call uri,$(MAKEFILEDIR)/xsl/merge-results-with-query.xsl) \
		-i conf=$(call uri,$(CODE)/conf/hogrefe_conf.xml) \
		-o result=$(call win_path,$@) \
		$(call uri,$(MAKEFILEDIR)/xpl/process-crossref-results.xpl) \
		input-dir-uri=$(call uri,$(CROSSREFTMP)) \
		tmp-suffix=".tmp" \
		2> $(CROSSREFTMP)/process-crossref-results.txt
	ls -l $(CROSSREFTMP)
	cat $(CROSSREFTMP)/files.txt
	@echo

fetchmail: $(abspath $(CROSSREFTMP))/files.txt
ifneq (,$(shell cat $<))
	echo shell $(shell cat $(abspath $<))
	echo unix $(call unix_paths,$<)
	-svn up $(call unix_paths,$<)
	-svn lock $(call unix_paths,$<)
	$(foreach file,$(call unix_paths,$<),mv $(file).tmp $(file); )
	-svn add --depth empty $(abspath $(addsuffix ..,$(dir $(call unix_paths,$<))))
	-svn add --depth empty $(dir $(call unix_paths,$<))
	-svn add $(call unix_paths,$<)
	-svn add $(addsuffix .jsx,$(basename $(call unix_paths,$<)))
	-svn ci --depth empty $(abspath $(addsuffix ..,$(dir $(call unix_paths,$<)))) -m automatic
	-svn ci --depth empty $(dir $(call unix_paths,$<)) -m automatic
	svn ci $(call unix_paths,$<) -m automatic
	svn ci $(addsuffix .jsx,$(basename $(call unix_paths,$<))) -m automatic
# Because of the needs-lock property set by hook: 
	svn up $(call unix_paths,$<)
	svn up $(addsuffix .jsx,$(basename $(call unix_paths,$<)))
	-rm $(CROSSREFTMP)/*
endif

remove_old_crossrefs:
	-svn up $(call unix_paths,$(abspath $(CROSSREFTMP))/files.txt)
	-svn rm $(call unix_paths,$(abspath $(CROSSREFTMP))/files.txt)
	-svn rm $(addsuffix .jsx,$(basename $(call unix_paths,$(abspath $(CROSSREFTMP))/files.txt)))
	-svn ci $(call unix_paths,$(abspath $(CROSSREFTMP))/files.txt) -m automatic
	-svn ci $(addsuffix .jsx,$(basename $(call unix_paths,$(abspath $(CROSSREFTMP))/files.txt))) -m automatic


.SECONDEXPANSION:

# This target will issue a crossref request
%.qb.xml: $$(subst crossref,hobots,$$(subst .qb,,$$@))
	echo "nun $@ erzeugen" >> $(ACTIONLOG)
	echo "ggf. Werkverzeichnis $(abspath $(addsuffix ..,$(dir $@))) erstellen" >> $(ACTIONLOG)
	-svn mkdir $(abspath $(addsuffix ..,$(dir $@)))
	-svn mkdir $(dir $@)
	$(CODE)/calabash/calabash.sh \
		-i source=$(call uri,$<) \
		-o qb=$(call win_path,$@) \
		$(call uri,$(MAKEFILEDIR)/xpl/jats-submit-crossref-query.xpl) \
		user=$(CROSSREFUSER) pass=$(CROSSREFPASS) \
		email=$(EMAIL)
	-svn ci --depth empty $(abspath $(addsuffix ..,$(dir $@))) -m automatic
	-svn ci $(dir $@) -m automatic
