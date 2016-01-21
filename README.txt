Prerequisites:

fetchmail
procmail
qprint (http://www.fourmilab.ch/webtools/qprint/) or another quoted-printable decoder

Copy infrastructure/fetchmailrc.template to infrastructure/fetchmailrc and infrastructure/procmailrc.template
to infrastructure/procmailrc, fill in all placeholders. Use absolute paths even if sth like ./procmailrc
suggests that you might get away with relative paths. You won't. 

chmod 600 fetchmailrc

Create and adapt local_defs.mk according to your needs.

In procmailrc, it should be necessary to use only one of base64 or qprint, not both. In the template,
there are both. Look at the mail that you are receiving and decide.

Establish a cron job that invokes 
make -f /path/to/crossref/Makefile fetchmail
There is a sample.sh for that. It invokes infrastructure/timestamp
