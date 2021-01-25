<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Web-Project</title>
    <link rel="stylesheet" href="styles/w3.css">
</head>
<body class="w3-light-gray">
<!-- header -->
    <div class="w3-container w3-blue-gray w3-opacity w3-right-align">
        <h1>Start page My Web app</h1>
    </div>

    <div>       <!-- content -->
        <div class="w3-container w3-center">
            <div><h1>Data <%= new java.util.Date()%></h1>
                <%= new Date()
                %>
                <%
                    response.setIntHeader("Refresh", 5);
                %>
                <br>
                <strong>Server Time&nbsp;:&nbsp;&nbsp;</strong><label id="timelable"></label>
            </div>
            <div class="w3-bar w3-padding-large w3-padding-24">    <!-- buttons holder -->
                <button class="w3-btn w3-hover-light-blue w3-round-large" onclick="location.href='/list'">List users</button>
                <button class="w3-btn w3-hover-light-green w3-round-large" onclick="location.href='/add'">Add user</button>
            </div>
            <!--<div>   &lt;!&ndash; Link holder &ndash;&gt;-->
                <!--<a href="/list">List users</a>-->
                <!--<a href="/add">Add user</a>-->
            <!--</div>-->
        </div>
    </div>

<script type="text/javascript">
    var myVar = setInterval(function(){ myTimer() }, 1000);
    var jsVar=  <%=java.util.Calendar.getInstance().getTimeInMillis()%>;
    var timeZoneOffset=<%=java.util.TimeZone.getDefault().getOffset(System.currentTimeMillis())%>;

    jsVar=jsVar+timeZoneOffset;
    function myTimer() {
        jsVar=jsVar+1000;
        var d = new Date(jsVar);
        var t=d.toUTCString();
        document.getElementById("timelable").innerHTML = t;
    }

</script>
</body>
</html>