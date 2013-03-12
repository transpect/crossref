# see http://publishinggeekly.com/2013/03/xproc-crossref-doi-lookup/
calabash/calabash.sh -i source=bits.xml -o qb=query_batch.xml email=X@Y user=USER pass=PASS crossref/xpl/jats-submit-crossref-query.xpl xpath='(//sec)[last()]'
