<?php
  $a=array("item1"=>"object1", "item2"=>"object2", "item3"=>"object3");
  echo http_build_query($a,'',' ');
?>
