<?php
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $feedbackid = $_POST["feedbackid"];

    $createdAt = $_POST["createdAt"];
    $photo_prefix = $_POST["photo_prefix"];
    $photo_suffix = $_POST["photo_suffix"];
    $rate = $_POST["rate"];
    $text = $_POST["text"];
    $name = $_POST["name"];
    $email = $_POST["email"];
    $venueid = $_POST["venueid"];
    $userid = $_POST["userid"];
    $device_id = $_POST["device_id"];
    $fields = "createdAt = '" . $createdAt . "', photo_prefix = '" . $photo_prefix . "', photo_suffix = '" . $photo_suffix . "', rate = '" . $rate . "', text = '". $text . "', name = '". $name . "', email = '". $email . "', venueid = '". $venueid . "', userid = '". $userid . "', device_id ='".$device_id."'";
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_update($db, 'feedbacks', "id = '" . $feedbackid . "'", $fields);
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
