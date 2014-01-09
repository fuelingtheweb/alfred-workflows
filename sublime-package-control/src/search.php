<?php
require('workflows.php');

$w = new Workflows();
$query = $argv[1];
$data = $w->request('https://sublime.wbond.net/search/' . $query . '.json');
$data = json_decode($data);
$packages = $data->packages;

$i = 0;
foreach($packages as $p){
	$description = preg_replace('/[\x00-\x1F\x7F]/', '', $p->highlighted_description);
	$w->result(
		$p->name, //id
		'https://sublime.wbond.net/packages/' . $p->name, //argument
		$p->name, //title
		$description, //subtitle
		'icon.png', //icon
		'yes', //autocomplete
		$p->name //autocomplete text
	);
}

echo $w->toxml();
