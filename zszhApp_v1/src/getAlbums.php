<?php
require 'includes/conn.php';//���ݿ����ӵ����ݶ�����ȥ��
session_start();
$uid=$_SESSION['user'];
$sql="......";//ʡ�Զ�ȡ����
$album=DBarray($sql);//�����ݿ��ȡ����
$result=null;
if($album)
{
 foreach ($album AS $idx => $row)
    {
     $output .= "<album>";
     $output .= "<albumid>";
     $output .= $album[$idx]['albumid'];
     $output .= "</albumid>";
     $output .= "<coverurl>";
     $output .= $album[$idx]['coverurl'];
     $output .= "</coverurl>";
     $output .= "<albumname>";
     $output .= $album[$idx]['name'];
     $output .= "</albumname>";
     $output .= "</album>";
    }
}
print ($output);
?>