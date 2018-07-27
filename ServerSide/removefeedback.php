<?php
    
    header('Content-Type: application/json');

   
    include 'mysqlparameters.php';
    
    // https://10.214.6.243:8080/removefeedback.php?feedbackid=34567899999999
    
    $feedbackid = $_REQUEST["feedbackid"];
    $filename = $_REQUEST["file"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $sql = mysql_query("DELETE FROM feedbacks WHERE id = '$feedbackid'" ,$db);
    
    $rows = array();
    $rows[status] = 1;

    if($sql == TRUE)
    {
        $fullfilename = 'data/' . $filename;
	$rows[filename] = $fullfilename;
        @unlink($fullfilename);

        $rows[result] = "YES";
    }
    else
    {
        $rows[result] = "NO";
    }
    echo json_encode($rows);
    mysql_close($db);
    ?>
