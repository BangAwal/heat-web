#!/bin/bash
sudo subscription-manager register --force --username=your-username --password=your-pass
sudo subscription-manager attach --auto
sudo yum repolist
yum install -y httpd php mysql php-mysqlnd
touch /var/www/html/index.php
cat << EOF > /var/www/html/index.php
<?php

\$conn = new mysqli('$db_private_ip', 'admin', 'redhat', 'mydb');

?>

<html>

<head>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css"
        integrity="sha384-xOolHFLEh07PJGoPkLv1IbcEPTNtaed2xpHsD9ESMhqIYd0nLMwNLD69Npy4HI+N" crossorigin="anonymous">
    <title>Employee Data</title>
</head>

<body>
    <?php
        if(isset(\$_POST['submit'])) {   
            \$name = \$_POST['name'];
            \$age = \$_POST['age'];
            if(empty(\$name) || empty(\$age) ) {              
                echo '<div class="alert alert-danger" role="alert"> Please input all the field!</div>';
            } else { 
                \$result = mysqli_query(\$conn, "INSERT INTO employee(name,age) VALUES('\$name','\$age')"); 
            }
        }
    ?>
    <div class="jumbotron">
        <h1 class="display-4">Simple Demo App</h1>
        <p class="lead">Multi tier App with apache server and mariadb</p>
        <hr class="my-4">
        <p>Add and Retrieve Data from mysql database</p>

        <form action="" method="post" name="">
            <div class="form-group">
                <label>Name</label>
                <input class="form-control" type="text" name="name">
            </div>
            <div class="form-group">
                <label>Age</label>
                <input class="form-control" type="text" name="age">
            </div>

            <input class="btn btn-primary" type="submit" name="submit" value="Add">
        </form>

        <table class="table">
            <thead class="thead-dark">
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Age</th>
                </tr>
            </thead>
            <tbody>
                <?php 
            \$result = mysqli_query(\$conn, "SELECT * FROM employee ORDER BY id DESC"); 

            while(\$res = mysqli_fetch_array(\$result)) {         
                echo "<tr>";
                echo "<td>".\$res['name']."</td>";
                echo "<td>".\$res['age']."</td>";
            }
        ?>
            </tbody>
        </table>

    </div>
</body>

</html>
EOF
setsebool -P httpd_can_network_connect_db=true
systemctl restart httpd; systemctl enable httpd
export response=$(curl -s -k \
--output /dev/null \
--write-out %{http_code} http://$web_public_ip/)
[[ ${response} -eq 200 ]] && $wc_notify \
--data-binary '{"status": "SUCCESS"}' \
|| $wc_notify --data-binary '{"status": "FAILURE"}'
