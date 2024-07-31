<html>
<body>
<?php

// database connection code
if(isset($_POST['txtName']))
{
// $con = mysqli_connect('localhost', 'database_user', 'database_password','database');
//$con = mysqli_connect('localhost', 'root', '','db_contact');

// get the post records

$txtName = $_POST['txtName'];
$txtEmail = $_POST['txtEmail'];
$txtPhone = $_POST['txtPhone'];
$txtMessage = $_POST['txtMessage'];
echo "Welcome $txtName";
$servername = "172.17.0.2";
$username = "root";
$password = "1234";

// Create connection
$conn = new mysqli($servername, $username, $password, 'db_contact');
echo "Connected";
// database insert SQL code
$sql = "INSERT INTO `tbl_contact` (`Id`, `fldName`, `fldEmail`, `fldPhone`, `fldMessage`) VALUES ('0', '$txtName', '$txtEmail', '$txtPhone', '$txtMessage')";
echo "Record Inserted";
// insert in database 
$rs = mysqli_query($conn, $sql);
if($rs)
{
        echo "Contact Records Inserted";
}
}
else
{
        echo "Are you a genuine visitor?";

}
?>


</body>
</html>
