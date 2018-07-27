<?php
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $username = $_REQUEST["username"];
    $email = $_REQUEST["email"];
    $password = $_REQUEST["password"];
    $phone = $_REQUEST["phone"];
    $device_id = $_REQUEST["device_id"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $query = "SELECT * FROM users WHERE email = '$email'";
    
    $sql = mysql_query($query, $db);
    $num_rows = mysql_num_rows($sql);
    
    if($num_rows == 0){
        $result = mysql_insert($db, 'users', array(
                                                   'name' => $username,
                                                   'email' => $email,
                                                   'password' => $password,
                                                   'contact' => $phone,
                                                   'device_id' => $device_id
                                                   ));
        //        if (!$result) {
        //            echo "Could not successfully run query (insert) from DB: " . mysql_error();
        //        }
    }
    else{
        $fields = "name = '" . $username . "', email = '" . $email . "', password = '" . $password . "', device_id = '" . $device_id . "', contact = '". $phone . "'";
        $result = mysql_update($db, 'users', "email = '" . $email . "'", $fields);
        //        if (!$result) {
        //            echo "Could not successfully run query (insert) from DB: " . mysql_error();
        //        }
    }
    
    $rows = array();
    $success = 0;
    
    $query = "SELECT * FROM users WHERE email = '$email'";
    
    $sql = mysql_query($query ,$db);
    
    while($r = mysql_fetch_assoc($sql)) {
        $rows[status] = 1;
        $rows[result] = "YES";
        $rows[user] = $r;
        $success = 1;
    }
    if($success == 0)
    {
        $rows[status] = 1;
        $rows[result] = "NO";
    }
    echo json_encode($rows);
    mysql_close($db);
    ?>

<?php
    function mysql_insert($db, $table, $inserts) {
        $values = array_map('mysql_real_escape_string', array_values($inserts));
        $keys = array_keys($inserts);
        $query = 'INSERT INTO `'.$table.'` (`'.implode('`,`', $keys).'`) VALUES (\''.implode('\',\'', $values).'\')';
        //        echo("   ".$query."    ");
        return mysql_query($query, $db);
    }
    function mysql_update($db, $table, $sql_condition, $fields) {
        $query = 'UPDATE `'.$table.'` SET '.$fields.' WHERE '.$sql_condition;
        return mysql_query($query, $db);
    }
    ?>
