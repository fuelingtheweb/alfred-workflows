#!/bin/bash

# Configuration
# -----------------------
# Folder where your new site folder will be saved. i.e. /Users/nathan/Development/web
parentFolder='/Users/nathan/Development/web'

# Folder where your sublime project and workspace files will be saved. i.e. /Users/nathan/Development/.sublime-projects
projectsFolder='/Users/nathan/Development/.sublime-projects'

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

# Begin Setup / Get Information
# -----------------------
# Set Up New Site
echo 'Begin creating new site.'

# Get Full Project Name
while true; do
    read -p "Project Name (Full): " projectName
    [  -z "$projectName" ] && echo "Enter a project name." || break
done

# Get Short Project Name
while true; do
    read -p "Project Name (Short/No Spaces): " shortName
    [  -z "$shortName" ] && echo "Enter a short project name." || break
done

# Create Database?
while true; do
    read -p "Create database? y/n: " createDB
    case $createDB in
        [Yy]* ) createDB=true; break;;
        [Nn]* ) createDB=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install Wordpress?
while true; do
    read -p "Install Wordpress? y/n: " installWP
    case $installWP in
        [Yy]* ) installWP=true; break;;
        [Nn]* ) installWP=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Initialize Git Repo?
while true; do
    read -p "Initialize New Git Repository? y/n: " initGit
    case $initGit in
        [Yy]* ) initGit=true; break;;
        [Nn]* ) initGit=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Get FTP Protocol
echo "Select FTP Protocol: "
select protocol in "FTP" "SFTP" "No FTP Setup"; do
	break
done

# If FTP Protocol Selected
transmitFav=false
sublimeSFTP=false
if [ "$protocol" != "No FTP Setup" ] ; then
	# Add Transmit Favorite?
	while true; do
	    read -p "Add Transmit Favorite? y/n: " transmitFav
	    case $transmitFav in
	        [Yy]* ) transmitFav=true; break;;
	        [Nn]* ) transmitFav=false; break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done

	# Add Sublime SFTP Config?
	while true; do
	    read -p "Add Sublime SFTP Configuration? y/n: " sublimeSFTP
	    case $sublimeSFTP in
	        [Yy]* ) sublimeSFTP=true; break;;
	        [Nn]* ) sublimeSFTP=false; break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done

	if $transmitFav || $sublimeSFTP ; then
		# Get Server Address
		while true; do
		    read -p "FTP Server Address: " ftpAddress
		    [  -z "$ftpAddress" ] && echo "Enter the FTP server address." || break
		done

		# Get User
		while true; do
		    read -p "FTP User: " ftpUser
		    [  -z "$ftpUser" ] && echo "Enter the FTP user." || break
		done

		# Get Password
		while true; do
		    read -p "FTP Password: " ftpPassword
		    [  -z "$ftpPassword" ] && echo "Enter the FTP password." || break
		done

		# Get Remote Path
		while true; do
		    read -p "FTP Remote Path: " ftpRemotePath
		    [  -z "$ftpRemotePath" ] && echo "Enter the FTP remote path." || break
		done
	fi
fi

while true; do
    read -p "Do you wish to proceed with the following options?
    Project Name (Full): $projectName
    Project Name (Short): $shortName
    Create Database: $createDB
    Install Wordpress: $installWP
    Initialize Git Repository: $initGit
    FTP Protocol: $protocol
    Add Transmit Favorite: $transmitFav
    Add Sublime SFTP Configuration: $sublimeSFTP

y/n: " proceed
    case $proceed in
        [Yy]* ) break;;
        [Nn]* ) echo "Site creation cancelled."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Process Site Creation
# -----------------------
# Create Site Folder
siteFolder="$parentFolder/$shortName"
echo "Creating site folder: $siteFolder"
mkdir "$siteFolder"

# Add Dev Domain
if $updateHosts ; then
	echo 'Adding dev domain to /etc/hosts. You may need to enter your password'
	sudo -- sh -c "echo '127.0.0.1 "$shortName"."$rootDomain"' >> /etc/hosts"
fi

# Add Domain Configuration
if $updateConfFile ; then
	echo "Adding site configuration to $confFile"
	echo "<VirtualHost *:80>
		DocumentRoot \"$siteFolder\"
		ServerName $shortName.$rootDomain
	</VirtualHost>" >> $confFile
fi

# Create sublime-project file
echo 'Creating sublime project file'
touch $projectsFolder/$shortName.sublime-project
echo '
{
	"folders":
	[
		{
			"path": "'$siteFolder'"
		}
	]
}
' > $projectsFolder/$shortName.sublime-project

# Create sublime-workspace file
echo 'Creating sublime workspace file'
touch $projectsFolder/$shortName.sublime-workspace
echo '
{
}
' > $projectsFolder/$shortName.sublime-workspace

# Enter site folder
cd "$siteFolder"

# Create Database
if $createDB ; then
	dbName="$dbPrefix$shortName"
	echo "Creating database: $dbName"
	mysql -u $dbUser -p$dbPass -e "create database $dbName;"
fi

# Install Wordpress
if $installWP ; then
	echo "Installing Wordpress"
	# Download
	curl -O http://wordpress.org/latest.tar.gz

	# Unzip
	tar -zxvf latest.tar.gz

	# Change dir to wordpress
	cd wordpress

	# Copy file to parent dir
	cp -rf . ..

	# Move back to parent dir
	cd ..

	# Remove files from wordpress folder
	rm -R wordpress

	# Create wp config
	cp wp-config-sample.php wp-config.php

	# Set database details with perl find and replace
	if $createDB ; then
		sed "s/database_name_here/$dbName/g" wp-config-sample.php | sed "s/username_here/$dbUser/g" | sed "s/password_here/$dbPass/g" > wp-config.php
	fi

	# Create uploads folder and set permissions
	mkdir wp-content/uploads
	chmod 777 wp-content/uploads

	# Remove zip file
	rm latest.tar.gz
fi

# Add Sublime SFTP Config
if $sublimeSFTP ; then
echo 'Adding Sublime SFTP Configuration File'
touch "$siteFolder/sftp-config.json"
echo '
{
	// The tab key will cycle through the settings when first created
	// Visit http://wbond.net/sublime_packages/sftp/settings for help

	// sftp, ftp or ftps
	"type": "'$protocol'",

	"save_before_upload": true,
	"upload_on_save": false,
	"sync_down_on_open": false,
	"sync_skip_deletes": false,
	"confirm_downloads": false,
	"confirm_sync": true,
	"confirm_overwrite_newer": false,

	"host": "'$ftpAddress'",
	"user": "'$ftpUser'",
	"password": "'$ftpPassword'",
	//"port": "22",

	"remote_path": "'$ftpRemotePath'",
	"ignore_regexes": [
		"\\.sublime-(project|workspace)", "sftp-config(-alt\\d?)?\\.json",
		"sftp-settings\\.json", "/venv/", "\\.svn", "\\.hg", "\\.git",
		"\\.bzr", "_darcs", "CVS", "\\.DS_Store", "Thumbs\\.db", "desktop\\.ini"
	],
	//"file_permissions": "664",
	//"dir_permissions": "775",

	//"extra_list_connections": 0,

	"connect_timeout": 30,
	//"keepalive": 120,
	"ftp_passive_mode": true,
	//"ssh_key_file": "~/.ssh/id_rsa",
	//"sftp_flags": ["-F", "/path/to/ssh_config"],

	//"preserve_modification_times": false,
	//"remote_time_offset_in_hours": 0,
	//"remote_encoding": "utf-8",
	//"remote_locale": "C",
}
' > "$siteFolder/sftp-config.json"
fi

# Initialize Git Repo
if $initGit ; then
	echo "Initializing Git Repository"
	git init && git add -A && git commit -m 'Initial Commit'
fi

# Add Transmit Favorite
if $transmitFav ; then
echo "Adding Transmit Favorite"
osascript <<EOD
	-- 'menu_click', by Jacob Rus, September 2006
	--
	-- Accepts a list of form: '{"Finder", "View", "Arrange By", "Date"}'
	-- Execute the specified menu item.  In this case, assuming the Finder
	-- is the active application, arranging the frontmost folder by date.

	on menu_click(mList)
		local appName, topMenu, r

		-- Validate our input
		if mList's length < 3 then error "Menu list is not long enough"

		-- Set these variables for clarity and brevity later on
		set {appName, topMenu} to (items 1 through 2 of mList)
		set r to (items 3 through (mList's length) of mList)

		-- This overly-long line calls the menu_recurse function with
		-- two arguments: r, and a reference to the top-level menu
		tell application "System Events" to my menu_click_recurse(r, ((process appName)'s ¬
			(menu bar 1)'s (menu bar item topMenu)'s (menu topMenu)))
	end menu_click

	on menu_click_recurse(mList, parentObject)
		local f, r

		-- 'f' = first item, 'r' = rest of items
		set f to item 1 of mList
		if mList's length > 1 then set r to (items 2 through (mList's length) of mList)

		-- either actually click the menu item, or recurse again
		tell application "System Events"
			if mList's length is 1 then
				click parentObject's menu item f
			else
				my menu_click_recurse(r, (parentObject's (menu item f)'s (menu f)))
			end if
		end tell
	end menu_click_recurse

	tell application "Transmit"
		set SuppressAppleScriptAlerts to true

		tell current tab of (make new document at end)
			connect to address "$ftpAddress" as user "$ftpUser" with password "$ftpPassword" with protocol $protocol with initial path "$ftpRemotePath"
			change location of local browser to path "$siteFolder"
		end tell
	end tell

	tell application "Transmit" to activate

	menu_click({"Transmit", "Favorites", "Add to Favorites…"})

	tell application "System Events"
		keystroke return
	end tell
EOD
fi

# Restart Server
echo 'Restarting Server...'
sudo apachectl restart

echo 'New site created successfully.'
