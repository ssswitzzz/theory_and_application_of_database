<!-- <?php

function calculatepi($n){
    $sum = 0;
    for($k=1; $k<=$n; $k++){
        $sum += 1/($k * $k);
    }
    $pi = sqrt(6 * $sum);
    return $pi;
    
}
$myPi = calculatepi(1000000);
echo "计算出的pi值：" . $myPi;
?> -->

<?php
$host = "";
$port = "";
$dbname = "";
$user = "";
$password = "";

// 创建连接
$conn_str = "host=$host port=$port dbname=$dbname user=$user password=$password";
$dbconn = pg_connect($conn_str);


$sql = "
    SELECT 
        p.productname, 
        c.companyname, 
        c.phone 
    FROM shippers s
    JOIN orders o ON s.shipperid = o.shipvia
    JOIN customers c ON o.customerid = c.customerid
    JOIN order_details od ON o.orderid = od.orderid
    JOIN products p ON od.productid = p.productid
    WHERE s.companyname = 'Speedy Express' 
      AND o.shipcity = 'Buenos Aires' 
      AND o.shippeddate BETWEEN '1997-05-19' AND '1998-02-19'
";

// 3. 执行查询
$result = pg_query($dbconn, $sql);

?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Northwind 订单物流查询系统</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; padding: 20px; }
        .container { max-width: 900px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { color: #2c3e50; text-align: center; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #3498db; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f1f1f1; }
        .info { margin-bottom: 15px; font-size: 0.9em; color: #7f8c8d; }
    </style>
</head>
<body>

<div class="container">
    <h2>Buenos Aires 订单详情查询</h2>
    <div class="info">
        查询条件：发往 Buenos Aires | 货运公司：Speedy Express | 时间：1997-05-19 至 1998-02-19
    </div>

    <table>
        <thead>
            <tr>
                <th>产品名称</th>
                <th>收货客户公司</th>
                <th>联系电话</th>
            </tr>
        </thead>
        <tbody>
            <?php
            // 4. 循环渲染数据
            if (pg_num_rows($result) > 0) {
                while ($row = pg_fetch_assoc($result)) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($row['productname']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['companyname']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['phone']) . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='3' style='text-align:center;'>未找到符合条件的记录</td></tr>";
            }
            ?>
        </tbody>
    </table>
</div>

</body>
</html>

<?php
// 5. 释放内存并关闭连接
pg_free_result($result);
pg_close($dbconn);
?>