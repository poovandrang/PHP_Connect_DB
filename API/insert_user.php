<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");





$servername = "localhost";
$username = "root";
$password = "";
$dbname = "php";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from POST request
$name = $_POST['name'];
$user_password = $_POST['password'];

// Insert data into the database
$sql = "INSERT INTO users (name, password) VALUES ('$name', '$user_password')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $conn->error));
}

$conn->close();
?>
