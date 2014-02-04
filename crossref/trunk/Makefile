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
unix_paths = $(shell cat $(abspath $(1)) /dev/null)
endif

ACTIONLOG = /dev/null

# The following variables should be set in local_defs.mk:

EMAIL=crossref@acme.com
USER=user
PASS=pass
CROSSREFTMP=~/crossref
FETCHMAIL=fetchmail
FIRE=true

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
	$(CODE)/calabash/calabash.sh -D \
		-i merging-stylesheet=$(call uri,$(MAKEFILEDIR)/xsl/merge-results-with-query.xsl) \
		-i conf=$(call uri,$(CODE)/conf/hogrefe_conf.xml) \
		-o result=$(call win_path,$@) \
		$(call uri,$(MAKEFILEDIR)/xpl/process-crossref-results.xpl) \
		input-dir-uri=$(call uri,$(CROSSREFTMP)) \
		tmp-suffix=".tmp" \
		2> $(CROSSREFTMP)/process-crossref-results.txt

fetchmail: $(abspath $(CROSSREFTMP))/files.txt
	$(foreach file,$(call unix_paths,$<),$(MAKE) -C $(MAKEFILEDIR) process_fetched FILE=$(file); )

process_fetched:
	-svn up $(FILE)
	-svn lock $(FILE)
	mv $(FILE).tmp $(FILE)
	-svn add --depth empty $(abspath $(addsuffix ..,$(dir $(FILE))))
	-svn add --depth empty $(dir $(FILE))
	-svn add $(FILE)
	-svn add $(addsuffix .jsx,$(basename $(FILE)))
	-svn ci --depth empty $(abspath $(addsuffix ..,$(dir $(FILE)))) -m automatic
	-svn ci --depth empty $(dir $(FILE)) -m automatic
	svn ci $(FILE) -m automatic
	svn ci $(addsuffix .jsx,$(basename $(FILE))) -m automatic
# Because of the needs-lock property set by hook: 
	svn up $(FILE)
	svn up $(addsuffix .jsx,$(basename $(FILE)))
	-rm $(CROSSREFTMP)/*


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
		email=$(EMAIL) fire=$(FIRE) 2>&1 >> $(ACTIONLOG)
	-svn ci --depth empty $(abspath $(addsuffix ..,$(dir $@))) -m automatic 2>&1 >> $(ACTIONLOG)
	-svn ci $(dir $@) -m automatic 2>&1 >> $(ACTIONLOG)

