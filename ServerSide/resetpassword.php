<?php
    header('Content-Type: application/json');
    
    include 'mysqlparameters.php';
    
    // https://10.214.6.243:8080/resetpassword.php?email=svmp%40ukr.net
    
    $email = $_REQUEST["email"];
    //$to_name = $_REQUEST["name"];
    //$subject = $_REQUEST["subject"];
    //$message = $_REQUEST["message"];

    $db = mysql_connect($mysqlUrl, $mySqlUser, $mySqlUserPassword);
    mysql_select_db($dbname, $db);
    $result = mysql_query("SELECT * FROM users WHERE email = '$email'", $db);
    
    $rows = array();
    $rows[status] = 1;
    $rows[result] = "NO";
    
    if ($result)
    {
        $r = mysql_fetch_assoc($result);
        
        if ($r)
        {
            $rows[result] = "YES";
//            $rows[user] = $r;
            $password = $r["password"];
//            $message = $message . $password;
            
            // To send HTML mail, the Content-type header must be set
//            $headers  = 'MIME-Version: 1.0' . "\r\n";
//            $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
            // Additional headers
//            $headers .= 'To: ' . $to_name . ' <' . $email . '>' . "\r\n";
//            $headers .= 'From: '. 'The Best Place' . ' <' . 'sergey.krotkih@gmail.com' . '>' . "\r\n";
            //$headers .= 'Cc: sergey.krotkih@gmail.com' . "\r\n";
            // Mail it
//            $success = mail($email, $subject, $message);
//            $rows[success] = $success;
              $rows[password] = $password; 
        }
    }
    
    echo json_encode($rows);
    mysql_close($db);
    ?>
