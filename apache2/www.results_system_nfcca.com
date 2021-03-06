<VirtualHost *:80>
        ServerAdmin webmaster@localhost

        ServerName www.results_system_nfcca.com

        # DocumentRoot /var/www
        DocumentRoot /home/duncan/git/results_system/forks/nfcca/public_html/
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
	<Directory /results_system/custom/nfcca>
	        AllowOverride FileInfo
	</Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/  /home/duncan/git/results_system/forks/nfcca/cgi-bin/
        # ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined

    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>

</VirtualHost>

