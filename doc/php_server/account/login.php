<?php
//***********************
// Logs into an account
//
// Send:
//  email, pass
//
// Receive:
//  1->user success login
//  2->user does not exist
//  3->incorrect pass
//***********************

//$email = strtolower($_POST['email']);
$email = $_POST['email'];
$pass = $_POST['pass'];

// Connect to database
require_once 'database.php'; 
$db_server = mysql_connect($db_hostname, $db_username, $db_password);
if (!$db_server) { 
	die("Unable to connect to MySQL: " . mysql_error());
}
mysql_select_db($db_database) or die("Unable to select database: " . mysql_error());

// Query usernames for a match
$query = "SELECT * FROM accounts";
$result = mysql_query($query);	
$rows = mysql_num_rows($result);
$exist = FALSE;
for ($j = 0 ; $j < $rows ; ++$j) {
	if($email == mysql_result($result,$j,'email')) {
		$exist = TRUE;
		$password2 = mysql_result($result,$j,'password');
		$firstName = mysql_result($result,$j,'first_name');
		$lastName = mysql_result($result,$j,'last_name');
		$email = mysql_result($result,$j,'email');
		$phone = mysql_result($result,$j,'phone');
		$address = mysql_result($result,$j,'address');
		$city = mysql_result($result,$j,'city');
		$state = mysql_result($result,$j,'state');
		$zip = mysql_result($result,$j,'zip');
		$photo = mysql_result($result,$j,'photo');
		$type = mysql_result($result,$j,'type');
	}
}

// Check if user exists
if(!$exist) {
	echo("2");
	exit();
}
	
// check if password is correct	
if($pass != $password2) {
	echo("3");
	exit();
}

// User successfully logged in
$userInfo['firstName'] = $firstName;
$userInfo['lastName'] = $lastName;
$userInfo['email'] = $email;
$userInfo['phone'] = $phone;
$userInfo['address'] = $address;
$userInfo['city'] = $city;
$userInfo['state'] = $state;
$userInfo['zip'] = $zip;
$userInfo['photo'] = $photo;
$userInfo['type'] = $type;

$JSON = json_encode($userInfo);

echo($JSON);

?>