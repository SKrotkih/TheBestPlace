<?php
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $feedbackid = $_REQUEST["feedbackid"];
    $venueid = $_REQUEST["venueid"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $query = "SELECT * FROM votes WHERE feedbackid = '$feedbackid' AND venueid = '$venueid'";
    
    $result = mysql_query($query, $db);
    
    $rows = array();
    $rows[status] = 1;
    $rows[result] = "NO";
    
    if ($result)
    {
        $likeCount = 0;
        $dislikeCount = 0;
        
        while($r = mysql_fetch_assoc($result))
        {
            if ($r[vote] > 0)
            {
                $likeCount = $likeCount + 1;
            }
            else
            {
                $dislikeCount = $dislikeCount + 1;
            }
        }

        $rows[like] = $likeCount;
        $rows[dislike] = $dislikeCount;
        $rows[result] = "YES";
    }
    
    echo json_encode($rows);
    mysql_close($db);
    ?>
