<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    //ttp://production.ainstainer.com/select_feedbacks.php?venueid=52d7018511d2e93127a4a298
    
    $venueid = $_REQUEST["venueid"];
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_query("SELECT * FROM feedbacks WHERE venueid = '$venueid'" ,$db);
    
    $rows = array();
    
    $success = 0;
    
    if ($result)
    {
        $success = 1;
        
        while($r = mysql_fetch_assoc($result)) {
            $rows[] = $r;
        }
    }
    
    $query2 = "SELECT feedbackid, COUNT(vote) as likeCount FROM votes WHERE venueid = '$venueid' AND vote > 0 GROUP BY feedbackid";
    
    $likeresult = mysql_query($query2, $db);
    
    $likerows = array();
    
    if ($likeresult)
    {
        while($r = mysql_fetch_assoc($likeresult))
        {
            $likerows[] = $r;
        }
    }
    
    $query3 = "SELECT feedbackid, COUNT(vote) as dislikeCount FROM votes WHERE venueid = '$venueid' AND vote <= 0 GROUP BY feedbackid";
    
    $dislikeresult = mysql_query($query3, $db);
    
    $dislikerows = array();
    
    if ($dislikeresult)
    {
        while($r = mysql_fetch_assoc($dislikeresult))
        {
            $dislikerows[] = $r;
        }
    }
    
    $query4 = "SELECT votes.feedbackid as feedbackid, users.firstname, users.lastname, users.name, users.photo_prefix, users.photo_suffix FROM votes INNER JOIN users ON votes.userid = users.id  WHERE ((votes.venueid = '$venueid') AND (votes.vote > 0))";
    
    $likeusersresult = mysql_query($query4, $db);
    
    $likeusersrows = array();
    
    if ($likeusersresult)
    {
        while($r = mysql_fetch_assoc($likeusersresult))
        {
            $likeusersrows[] = $r;
        }
    }
    
    $query5 = "SELECT votes.feedbackid as feedbackid, users.firstname, users.lastname, users.name, users.photo_prefix, users.photo_suffix FROM votes INNER JOIN users ON votes.userid = users.id  WHERE ((votes.venueid = '$venueid') AND (votes.vote <= 0))";
    
    $dislikeusersresult = mysql_query($query5, $db);
    
    $dislikeusersrows = array();
    
    if ($dislikeusersresult)
    {
        while($r = mysql_fetch_assoc($dislikeusersresult))
        {
            $dislikeusersrows[] = $r;
        }
    }
    
    $data = array();
    $data[status] = 1;
    
    if($success == 1)
    {
        $data[result] = "YES";
        $data[data] = $rows;
        $data[like] = $likerows;
        $data[dislike] = $dislikerows;
        $data[likeusers] = $likeusersrows;
        $data[dislikeusers] = $dislikeusersrows;
    }
    else
    {
        $data[result] = "NO";
    }
    
    echo json_encode($data);
    mysql_close($db);
    ?>
