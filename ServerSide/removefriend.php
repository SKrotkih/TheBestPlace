<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $userid = $_REQUEST["userid"];
    $friendid = $_REQUEST["friendid"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $sql = mysql_query("DELETE FROM friends WHERE userid = '$userid' AND friendid = '$friendid'" ,$db);
    
    $rows = array();
    $rows[status] = 1;
    if($sql == TRUE)
    {
        $rows[result] = "YES";
    }
    else
    {
        $rows[result] = "NO";
    }
    echo json_encode($rows);
    mysql_close($db);
    ?>
