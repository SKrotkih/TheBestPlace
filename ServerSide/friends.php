<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $userid = $_REQUEST["userid"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_query("SELECT * FROM users WHERE id IN (SELECT friendid FROM friends WHERE userid = '$userid')" ,$db);
    
    $rows = array();
    
    $success = 0;
    
    if ($result)
    {
        $success = 1;
        
        while($r = mysql_fetch_assoc($result)) {
            $rows[] = $r;
        }
    }
    
    $data = array();
    $data[status] = 1;
    
    if($success == 1)
    {
        $data[result] = "YES";
        $data[data] = $rows;
    }
    else
    {
        $data[result] = "NO";
    }
    
    echo json_encode($data);
    mysql_close($db);
    ?>
