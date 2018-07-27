<?php
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $userid = $_REQUEST["userid"];
    $feedbackid = $_REQUEST["feedbackid"];
    $device_id = $_REQUEST["device_id"];
    $venueid = $_REQUEST["venueid"];
    $vote = $_REQUEST["vote"];
    $createdAt = $_REQUEST["createdAt"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $query = "SELECT * FROM votes WHERE userid = '$userid' AND feedbackid = '$feedbackid' AND device_id = '$device_id' AND venueid = '$venueid' AND vote = '$vote'";
    
    $result = mysql_query($query, $db);
    
    $rows = array();
    $rows[status] = 1;
    $rows[result] = "NO";
    
    if ($result)
    {
        $r = mysql_fetch_assoc($result);
        
        if ($r)
        {
        }
        else
        {
            $result = mysql_insert($db, 'votes', array('userid' => $userid,
                                                       'feedbackid' => $feedbackid,
                                                       'device_id' => $device_id,
                                                       'venueid' => $venueid,
                                                       'vote' => $vote,
                                                       'createdAt' => $createdAt
                                                       ));
            if ($result)
            {
                $rows[result] = "YES";
            }
        }
    }
    
    echo json_encode($rows);
    mysql_close($db);
    ?>

<?php
    function mysql_insert($db, $table, $inserts) {
        $values = array_map('mysql_real_escape_string', array_values($inserts));
        $keys = array_keys($inserts);
        $query = 'INSERT INTO `'.$table.'` (`'.implode('`,`', $keys).'`) VALUES (\''.implode('\',\'', $values).'\')';
        return mysql_query($query, $db);
    }
    function mysql_update($db, $table, $sql_condition, $fields) {
        $query = 'UPDATE `'.$table.'` SET '.$fields.' WHERE '.$sql_condition;
        return mysql_query($query, $db);
    }
    ?>
