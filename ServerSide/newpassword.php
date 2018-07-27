<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $tablename = "users";
    
    $userid = $_REQUEST["userid"];
    $password = $_REQUEST["password"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $fields = "password = '" . $password . "'";
    
    $result = mysql_update($db, $tablename, "id = '" . $userid . "'", $fields);
    
    $rows = array();
    $rows[status] = 1;
    if ($result)
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
