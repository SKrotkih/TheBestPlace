<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    // https://10.214.6.243:8080/newpassword.php?userid=10&password=123
    
    $tablename = "users";
    
    $userid = $_REQUEST["userid"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_query("SELECT * FROM users WHERE id = '$userid'" ,$db);
    
    $rows = array();
    $success = 0;
    
    if ($result)
    {
        $success = 1;
        
        while($r = mysql_fetch_assoc($result)) {
            $rows[] = $r;
        }
    }
    
    $rows[status] = $success;
    $rows[result] = "YES";
    echo json_encode($rows);
    mysql_close($db);
    ?>