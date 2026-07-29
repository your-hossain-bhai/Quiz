<?php
header("Content-Type: application/json");
echo json_encode([
    "status" => "success", 
    "message" => "Quiz App BDApps API is running.",
    "version" => "1.0"
]);
?>
