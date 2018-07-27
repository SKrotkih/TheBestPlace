<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    // http://10.214.6.243:8080/signin.php?password=12345&email=svmp%40ukr.net
    
    $password = $_REQUEST["password"];
    $email = $_REQUEST["email"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_query("SELECT * FROM users WHERE email = '$email' AND password = '$password'", $db);
    
    $rows = array();
    $rows[status] = 1;
    $rows[result] = "NO";
    
    if ($result)
    {
        $r = mysql_fetch_assoc($result);
        
        if ($r)
        {
            $rows[result] = "YES";
            $rows[user] = $r;
        }
    }
    
    echo json_encode($rows);
    mysql_close($db);
    ?>
