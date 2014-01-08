<?php
require('workflows.php');

$type = $argv[1];

if($type == 'options'){
	$w = new Workflows();
	$query = $argv[2];
	if(strlen($query) < 1 || preg_match('/^' . $query . '/i', 'restart')){
		$w->result(
			'apachectl.restart',
			'sudo apachectl restart',
			'Restart Apache Server',
			'sudo apachectl restart',
			'img/server.png',
			'yes',
			'restart'
		);
	}
	if(strlen($query) < 1 || preg_match('/^' . $query . '/i', 'start')){
		$w->result(
			'apachectl.start',
			'sudo apachectl start',
			'Start Apache Server',
			'sudo apachectl start',
			'img/server.png',
			'yes',
			'start'
		);
	}
	if(strlen($query) < 1 || preg_match('/^' . $query . '/i', 'stop')){
		$w->result(
			'apachectl.stop',
			'sudo apachectl stop',
			'Stop Apache Server',
			'sudo apachectl stop',
			'img/server.png',
			'yes',
			'stop'
		);
	}
	if(strlen($query) < 1 || preg_match('/^' . $query . '/i', 'new project')){
		$w->result(
			'new.project',
			'new.project',
			'New Project',
			'Start new development project (Hold down command to proceed)',
			'img/hosting.png',
			'yes',
			'new project'
		);
	}

	echo $w->toxml();
} else {
	$command = $argv[2];
	if(preg_match('/apachectl/i', $command)){
		exec('osascript -e \'do shell script "' . $command . '" with administrator privileges\'');
		echo 'Command Executed: ' . $command;
	} else if ($command == 'setup.installer'){
		$w = new Workflows();
		exec('cp "' . $w->path() . '/newsite.sh" ~/.fuel_newsite.sh');
		echo 'Edit the configuration settings in ' . $w->home() . '/.fuel_newsite.sh';
	}
}
