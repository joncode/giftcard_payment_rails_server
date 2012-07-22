<?php
//***********************
// Creates an account
//
// Send:
//  data (JSON user data)
//
// Receive:
//  1->success
//***********************

// Get data
$data = $_POST['data'];

// Decode JSON
$dataArray = json_decode($data, true);

// Check data recieved
if (empty($data)) {
	die("Data not received correctly");
}

// Connect to database
require_once 'database.php'; 
$db_server = mysql_connect($db_hostname, $db_username, $db_password);
if (!$db_server) { 
	die("Unable to connect to MySQL: " . mysql_error());
}
mysql_select_db($db_database) or die("Unable to select database: " . mysql_error());

// Insert contact into database
$sql = "
	INSERT INTO accounts (phone, first_name, last_name, email, address, city, state, zip)
	VALUES ('" . $dataArray[phone] . "','" . $dataArray[firstName] . "', '" . $dataArray[lastName] . "', '" . $dataArray[email] . "'
		  , '" . $dataArray[address] . "', '" . $dataArray[city] . "', '" . $dataArray[state] . "', '" . $dataArray[zip] . "')
	";

// Perform query
$result = mysql_query($sql);

// Check result 
if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
    die($message);
}











?>