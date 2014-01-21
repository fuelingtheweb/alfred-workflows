Web Development
================

[Download Workflow](https://github.com/fuelingtheweb/alfred-workflows/blob/master/web-development/Web%20Development.alfredworkflow?raw=true)

**To update to use the latest new site script, run this command in Terminal:**

*Note: This will overwrite your configurations. So, you'll need to change the configuration settings again.*

	curl https://raw.github.com/fuelingtheweb/alfred-workflows/master/web-development/src/newsite.sh > ~/.fuel_newsite.sh

---

Run various web development tasks using the keyword `.dev`.

**Included tasks:**

- Restart Apache Server
- Start Apache Server
- Stop Apache Server
- New Project

**New Project**

This task allows you to quickly set up a new site for local development with the following options:

- Create a database
- Install Wordpress
- Initialize a Git Repository
- Set up FTP access through Transmit/Sublime SFTP

Before using the New Project task, you must select this item while holding `alt` to copy the new site script to your home folder. After the file is moved, edit the following configuration settings in ~/.fuel_newsite.sh.

	# Configuration
	# -----------------------
	# Folder where your new site folder will be saved. i.e. /Users/nathan/Sites/My Site/dev
	parentFolder='/Users/nathan/Sites'

	# Folder where your sublime project and workspace files will be saved. i.e. /Users/nathan/Sites/_Projects
	projectsFolder='/Users/nathan/Sites/_Projects'

	# Path to your user's apache configuration file
	confFile='/etc/apache2/users/nathan.conf'
	updateConfFile=true

	# Root domain for your local environment
	rootDomain='dev.site_name.com'

	# Add development domain to /etc/hosts
	updateHosts=true

	# Database Configruation Options
	dbPrefix="dev_"
	dbUser="root"
	dbPass="password_goes_here"

	# Use Git Flow (true) or standard Git (false)
	useGitFlow=false

	# If using Git Flow, should the defaults be used?
	useGitFlowDefaults=true

After configuring this task, you must hold `cmd` when you select the task in order to run the script as a terminal command.
