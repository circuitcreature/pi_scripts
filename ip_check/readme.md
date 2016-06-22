ip_change.sh

	This script will send you an email when the IP, public or local, changes.

	symlink or copy to the cron.hourly


	This currently only works with ethernet.

	Dependencies
		-postfix
		-mailutils

	debain based

	sudo apt-get install postfix
	sudo apt-get install mailutils

	sudo postconf -e 'relay_domains = raspberrypi.com'
	sudo postconf -e 'myorigin = raspberrypi.com'
