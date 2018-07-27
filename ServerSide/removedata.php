<?php
    header('Content-Type: application/json');
    
    $filename = $_POST["file"];
    $fullfilename = 'data/' . $filename;
    
    @unlink($fullfilename);
    
    $rows = array();
    $rows[status] = 1;
    $rows[result] = "YES";
    
    echo json_encode($rows);
    mysql_close($db);
    ?>
