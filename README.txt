Crossref query and result processing automation. The input is expected to be JATS-like mixed-citations.

The query result may be converted to an InDesign script that adds linked DOIs to paragraphs with the
style 'p_ref'. (It is expected that the conversion from this enriched IDML to JATS-like XML will exclude
paragraphs that already contain DOIs.)


Paths and placeholders:

We refer to the the parent directory of Makefile's CROSSREFTMP=$(CODE)/../tmp/crossref as 
/path/to/CROSSREFRESULTS in the sample fetchmail and procmail RCs.
$(CROSSREFTMP) is a directory whose contents will be deleted after polling the Crossref query answer
recipient's mail account. The parent directory of $(CROSSREFTMP) holds log files that are not very precious
but that should not be deleted after each polling.
$(CODE) is the transpect project directory. /path/to/crossref/ in the fetchmailrc should correspond to
$(CODE)/crossref/ if https://github.com/transpect/crossref is mounted as an external or submodule below $(CODE).


Prerequisites:

fetchmail 6.3.21 or newer
procmail
possibly qprint (http://www.fourmilab.ch/webtools/qprint/) or another quoted-printable decoder
GNU make 3.81 or newer


Steps:

1. Copy infrastructure/fetchmailrc.template to infrastructure/fetchmailrc and infrastructure/procmailrc.template
to infrastructure/procmailrc, fill in all placeholders. Use absolute paths everywhere.

2. chmod 600 fetchmailrc

3. Create and adapt local_defs.mk from local_defs.sample.mk according to your needs.

4. In procmailrc, it should be necessary to use at most one of base64 or qprint, not both. In the template,
there are both. Look at the mail that you are receiving and delete the filter line that you don't need
(if you delete the qprint line, don't forget to remove the trailing backslash in the base64 line).
It is also possible that the mails will already be stored as UTF-8. In this case, you only need the lower 
block that starts with :0b:

5. Create a script, for ex. infrastructure/fetch_and_process_crossref.sh, like this:

#!/bin/bash
/usr/bin/make -Bf /path/to/crossref/Makefile fetchmail 2>&1 > /path/to/CROSSREFRESULT/fetchmail-process-log_$(/bin/date '+%Y-%m-%d_%H-%M').txt

Make sure it's executable. 

6. Create an empty fetchmail log file that corresponds to the path that you've chosen in fetchmailrc
You can skip this and let the backup_conf make target do the work (see 9. below).

7. Create a crontab entry like this:

*/5 * * * * /path/to/crossref/infrastructure/fetch_and_process_crossref.sh

in order to make it poll the results every 5 minutes. Did we mention that you should use full paths 
everywhere?

8. Test the whole process by submitting a crossref request like
make -Bf /path/to/crossref/Makefile /path/to/work/crossref/work_basename.qb.xml
will look for /path/to/work/$(XMLSUBDIR)/work_basename.xml, convert it to a Crossref query body
and post it with the given Crossref credentials.

9. Create a backup of local_defs.mk, infrastructure/fetchmailrc, infrastructure/procmailrc, and maybe
also the crontab and the empty log file. We created a make target 'backup_conf' for this. It will 
create an empty fetchmail log file. It will delete an existing fetchmail log file first.
Store this backup in a safe place.

10. Remember not to store credentials in revision control repositories.


Creating a post-conversion action for the transpect web frontend is out of scope for this readme.
Ask gerrit.imsieke@le-tex.de or maren.pufe@le-tex.de for advice on setting this up.
