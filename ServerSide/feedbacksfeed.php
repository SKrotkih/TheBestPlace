<?php
    
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    
    $userid = $_REQUEST["userid"];
    $users = $_REQUEST["users"];
    
    if ($users == '-1')
    {
        $users = '';
        
        if ($userid == '-1')
        {
        }
        else
        {
            $result = mysql_query("SELECT friends.friendid as userid FROM friends WHERE friends.userid = '$userid'" ,$db);
            
            if ($result)
            {
                while($r = mysql_fetch_assoc($result)) {
                    $users .=  $r[userid];
                    $users .=  ",";
                }
                $users .= $userid;
            }
        }
    }
    
    $request1 = "SELECT feedbacks.id as feedbackid, feedbacks.venueid, feedbacks.categoryid, feedbacks.venuename, feedbacks.createdAt as date, feedbacks.text as description, users.firstname, users.lastname, users.name, feedbacks.rate FROM feedbacks INNER JOIN users ON feedbacks.userid = users.id";
    
    if ($users == '')
    {
    }
    else
    {
        $request1 .= " AND users.id IN ($users)";
    }
    
    $request3 = "SELECT votes.id as voteid, users.firstname, users.lastname, users.name FROM votes INNER JOIN users ON votes.userid = users.id";
    
    if ($users == '')
    {
    }
    else
    {
        $request3 .= " AND users.id IN ($users)";
    }
    
    
    $result = mysql_query($request1, $db);
    
    $feedbacks = array();
    $success = 0;
    
    if ($result)
    {
        $success = 1;
        while($r = mysql_fetch_assoc($result))
        {
            $feedbacks[] = $r;
        }
    }
    
    $result2 = mysql_query("SELECT votes.id as voteid, feedbacks.venueid, feedbacks.categoryid, feedbacks.venuename, votes.createdAt as date, votes.vote, feedbacks.id as feedbackid FROM feedbacks INNER JOIN votes ON feedbacks.id = votes.feedbackid ORDER BY date DESC", $db);
    
    $votes = array();
    
    if ($result2)
    {
        while($r = mysql_fetch_assoc($result2))
        {
            $votes[] = $r;
        }
    }
    
    $result3 = mysql_query($request3, $db);
    
    $users = array();
    
    if ($result3)
    {
        while($r = mysql_fetch_assoc($result3))
        {
            $users[] = $r;
        }
    }
    
    //    feedbacks
    //    `id` int(10) unsigned NOT NULL auto_increment,
    //    `userid` int(10) unsigned NOT NULL default 0,
    //    `venueid` varchar(64) NOT NULL default '',
    //    `rate` int(3) unsigned NOT NULL default 0,
    //    `createdAt` int(10) unsigned NOT NULL default 0,
    //
    //    users by id = feedbacks->userid
    //    `firstname` varchar(128) NOT NULL default '',
    //    `lastname` varchar(128) NOT NULL default '',
    //    `name` varchar(128) NOT NULL default '',
    //
    //    votes by feedbackid = feedbacks->id
    //    `userid` int(10) unsigned NOT NULL default 0,
    //    `createdAt` int(10) unsigned NOT NULL default 0,
    //    `vote` int(1) unsigned NOT NULL default 0,
    
    $data = array();
    
    $data[status] = 1;
    
    if($success == 1)
    {
        $data[result] = "YES";
        $data[feedbacks] = $feedbacks;
        $data[votes] = $votes;
        $data[users] = $users;
    }
    else
    {
        $data[result] = "NO";
    }
    
    echo json_encode($data);
    mysql_close($db);
    ?>
