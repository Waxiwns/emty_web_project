1. https://javarush.ru/groups/posts/305-sozdanie-prosteyshego-web-proekta-v-intellij-idea-enterprise-edition-poshagovo-s-kartinkami
2. https://javarush.ru/groups/posts/328-sozdanie-prostogo-veb-prilozhenija-na-servletakh-i-jsp-chastjh-1
3. https://javarush.ru/groups/posts/356-sozdanie-prostogo-veb-prilozhenija-na-servletakh-i-jsp-chastjh-2

Создание простого веб-приложения на сервлетах и jsp (часть 2)

Уровень знаний, необходимых для понимания статьи: вы уже более-менее разобрались с Java Core и хотели бы посмотреть на JavaEE-технологии и web-программирование. Логичнее всего, если вы сейчас изучаете квест Java Collections, где рассматриваются близкие статье темы.  


Создаем сущности
В пакете entities создадим класс User, ну а в нём — две приватные строковые переменные name и password. Создадим конструкторы (по умолчанию и такой, который бы принимал оба значения), геттеры/сеттеры, переопределим метод toString() на всякий случай, а также методы equals() и hashCode(). То есть сделаем всё то, что делает приличный Java-разработчик при создании класса. 

public class User {
    private String name;
    private String password;

    public User() {
    }

    public User(String name, String password) {
        this.name = name;
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", password='" + password + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        User user = (User) o;

        if (name != null ? !name.equals(user.name) : user.name != null) return false;
        return password != null ? password.equals(user.password) : user.password == null;

    }

    @Override
    public int hashCode() {
        int result = name != null ? name.hashCode() : 0;
        result = 31 * result + (password != null ? password.hashCode() : 0);
        return result;
    }
}

Теперь можем приступать к созданию списка пользователей. В него будем добавлять пользователей, и откуда будем их забирать для отображения. Однако здесь есть одна проблема. Объекты наших сервлетов создаем не мы, за нас это делает Tomcat. Методы, которые мы переопределяем в них, тоже уже определены за нас, и добавить параметр мы не можем. Как же тогда создать общий список, который был бы виден в обоих наших сервлетах? Если мы просто в каждом сервлете создадим свой объект списка, то получится, что добавлять пользователей мы будем в один список, а выводить список пользователей сервлетом ListServlet — в другой.

Выходит, нам нужен такой объект, который был бы общим для обоих сервлетов. Если говорить обобщенно, нам нужен такой объект, который был бы общим для всех классов в нашей программе; единственный объект на всю программу.

Надеюсь, вы что-то слышали про шаблоны проектирования. И, возможно, для кого-то это первая реальная необходимость использования шаблона Singleton в своей программе. 

Можете извратиться и «запилить» какой-нибудь крутой Singleton, с двойными проверками и синхронизациями (да-да, у нас многопоточное приложение, так как сервлеты Tomcat запускает в разных потоках), но я буду использовать вариант с ранней инициализацией, поскольку здесь его вполне хватает, и он подходит для наших целей. 

Создание модели
Создадим класс (и реализуем в нем шаблон Singleton) в пакете model и назовем его как-нибудь необычно. Скажем, Model.

Создадим в нашем классе приватный объект списка пользователей, и реализуем два метода: один для того, чтоб можно было добавить пользователя, а второй для возврата списка строк (имен пользователей). Поскольку наш объект пользователя состоит из имени и пароля, а пароли пользователей мы «светить» не хотели бы, будем только список имен.

public class Model {
    private static Model instance = new Model();

    private List model;

    public static Model getInstance() {
        return instance;
    }

    private Model() {
        model = new ArrayList<>();
    }

    public void add(User user) {
        model.add(user);
    }

    public List list() {
        return model.stream()
                .map(User::getName)
                .collect(Collectors.toList());
    }
}

Немного про mvc
Раз уж вы слышали про singleton, значит возможно слышали и про другой шаблон проектирования — MVC (model-view-controller, по-русски модель-представление-контроллер, или прям так как и на английском модель-вью-контроллер).

Его суть в том, чтобы отделять бизнес-логику от представления. То есть, отделять код, который определяет, что делать от кода, который определяет, как отображать. View (представление или просто вьюхи) отвечает за то, в каком виде представлять какие-то данные. В нашем случае вьюхи — это наши jsp-странички. Именно поэтому я их и положил в папочку с названием views.

Модель — это собственно сами данные, с которыми работает программа. В нашем случае это пользователи (список пользователей). Ну а контроллеры — связующее звено между ними. Берут данные из модели и передают их во вьюхи (или получают от Tomcat какие-то данные, обрабатывают их и передают модели). Бизнес-логику (что именно программа должна делать) нужно описывать в них, а не в модели или во вьюхе. Таким образом, каждый занимается своим делом:

модель хранит данные;
вьюхи рисуют красивое представление данных;
контроллеры занимаются обработкой данных.

Это позволяет программе быть достаточно простой и поддерживаемой, а не монструозной свалкой всего кода в одном классе.

MVC подходит не только для веб-программирования, но именно в этой сфере он встречается особенно часто (едва ли не всегда).

В нашем случае в качестве контроллеров будут выступать сервлеты.

Это очень поверхностное и краткое описание паттерна, но MVC — не главная тема этой статьи. Кто хочет узнать больше — Google в помощь! 
Создаем форму добавления пользователя

Добавим в файл add.jsp форму, состоящую из двух текстовых полей ввода (одно обычное, другое — пароль) и кнопки для отправки данных на сервер.

<form method="post">
    <label>Name:
        <input type="text" name="name"><br />
    </label>

    <label>Password:
        <input type="password" name="pass"><br />
    </label>
    <button type="submit">Submit</button>
</form>


Здесь у формы указан атрибут method со значением post. Это говорит о том, что данные из этой формы полетят на сервер в виде POST-запроса. Атрибут action не указан, значит запрос отправится по тому же адресу, по которому мы перешли на эту страничку (/add). Таким образом, наш сервлет, привязанный к этому адресу, при получении GET-запроса возвращает эту jsp с формой добавления пользователей, а если получит POST-запрос, значит, форма отправила туда свои данные (которые мы в методе doPost() вытащим из объекта запроса, обработаем и передадим в модель на сохранение).

Стоит обратить внимание, что у полей ввода указан параметр name (для поля с именем он имеет значение name, а для поля с паролем — pass). Это довольно важный момент. Так как чтобы получить из запроса (внутри сервлета уже) эти данные (имя и пароль которые будут введены) — мы будем использовать именно эти name и pass. Но об этом чуть позже.

Сама кнопка отправки данных у меня сделана снова же в виде button, а не полем вывода, как это обычно принято. Не знаю насколько такой вариант универсален, но у меня работает (браузер Chrome). 

Обработка POST-запроса сервлетом
Вернемся к сервлету AddServlet. Напомню: чтобы наш сервлет умел «ловить» GET-запросы, мы переопределили метод doGet() из класса HttpServlet. Чтобы научить наш сервлет отлавливать ещё и POST-звапросы, нам нужно переопределить еще и метод doPost(). Он получает аналогичные объекты запроса и ответа от Tomcat, с которыми мы и будем работать.

Для начала вытащим из запроса параметры name и pass, которые отправила форма (если вы их в форме назвали по-другому — тогда именно те названия и пишете). После этого создадим объект нашего пользователя, используя полученные данные. Потом получим объект модели и добавим созданного пользователя в модель.

@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String name = req.getParameter("name");
    String password = req.getParameter("pass");
    User user = new User(name, password);
    Model model = Model.getInstance();
    model.add(user);
}

Передача данных во view
Перейдем к сервлету ListServlet. Тут уже реализован метод doGet(), который просто передает управление во вьюху list.jsp. Если у вас этого еще нет — сделайте по аналогии с таким же методом из сервлета AddServlet.

Теперь было бы неплохо получить из модели список имен пользователей и передать их во вьюху, которая их получит и красивенько отобразит. Для этого снова воспользуемся объектом запроса, который мы получили от Tomcat. К этому объекту мы можем добавить атрибут, дав ему какое-то имя, и, собственно, сам объект, который бы мы хотели передать во view.

Благодаря тому, что при передаче процесса выполнения из сервлета во вьюху мы передаем туда эти же объекты запроса и ответа, что получил сам сервлет, то и добавив наш список имен к объекту запроса мы потом из этого объекта запроса во вьюхе сможем наш список имен пользователей и получить.

С классом ListServlet мы закончили, поэтому привожу код всего класса:

package app.servlets;

import app.model.Model;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class ListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Model model = Model.getInstance();
        List names = model.list();
        req.setAttribute("userNames", names);

        RequestDispatcher requestDispatcher = req.getRequestDispatcher("views/list.jsp");
        requestDispatcher.forward(req, resp);
    }
}

Выполнение java-кода в jsp-файлах
Пришла пора заняться файлом list.jsp. Он выполнится только когда ListServlet передаст сюда процесс выполнения. Кроме того, мы в том сервлете уже подготовили список имен пользователей из модели и передали сюда в объекте запроса.
Поскольку у нас есть список имён, мы можем пробежаться по нему циклом for и вывести каждое имя.

Как я уже говорил, jsp-файлы могут выполнять java-код (чем и отличаются от статичных html-страничек). Для того, чтобы выполнить какой-то код, достаточно поставить в нужном нам месте конструкцию:

<!-- html код -->
<%
    // java код
%>
<!-- html код -->

Внутри такой конструкции мы получаем доступ к нескольким переменным:

request — наш объект запроса, который мы передали из сервлета, где он назывался просто req;
responce — объект ответа, в сервлете назывался resp;
out — объект типа JspWriter (наследуется от обычного Writer), при помощи которого можем «писать» что-либо прямо в саму html-страничку. Запись out.println(«Hello world!») очень похожа на запись System.out.println(«Hello world!»), но не путайте их!
out.println() «пишет» в html-страничку, а System.out.println — в системный вывод. Если вызвать внутри раздела с Java-кодом jsp-метод System.out.println() — то результаты увидите в консоли Tomcat, а не на страничке.

Про другие доступные объекты внутри jsp можно поискать тут.

Используя объект request, мы можем получить список имен, который передавали из сервлета (мы прикрепили соответствующий атрибут к этому объекту), а используя объект out — можем вывести эти имена. Сделаем это (пока просто в виде html-списка):

<ul>
    <%
        List<String> names = (List<String>) request.getAttribute("userNames");

        if (names != null && !names.isEmpty()) {
            for (String s : names) {
                out.println("<li>" + s + "</li>");
            }
        }
    %>
</ul>

Если нужно выводить список только в том случае, когда есть пользователи, а иначе выводить предупреждение, что пользователей пока нет, можем немного переписать этот участок:

<%
    List<String> names = (List<String>) request.getAttribute("userNames");

    if (names != null && !names.isEmpty()) {
        out.println("<ui>");
        for (String s : names) {
            out.println("<li>" + s + "</li>");
        }
        out.println("</ui>");
    } else out.println("<p>There are no users yet!</p>");
%>

Теперь, когда мы умеем передавать данные из сервлетов во вьюхи, можем немного улучшить наш AddServlet, чтобы выводилось уведомление об успешном добавлении пользователя. Для этого в методе doPost() после того, как добавили нового пользователя в модель, можем добавить имя этого пользователя в атрибуты объекта req и передать управление обратно во вьюху add.jsp. А в ней уже сделать участок с Java-кодом, в котором происходит проверка, есть ли такой атрибут в запросе, и если да — то вывод сообщения о том, что пользователь успешно добавлен.

После этих изменений полный код сервлета AddServlet будет выглядеть примерно так:

package app.servlets;

import app.entities.User;
import app.model.Model;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AddServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        RequestDispatcher requestDispatcher = req.getRequestDispatcher("views/add.jsp");
        requestDispatcher.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String password = req.getParameter("pass");
        User user = new User(name, password);
        Model model = Model.getInstance();
        model.add(user);

        req.setAttribute("userName", name);
        doGet(req, resp);
    }
}

Тут в конце метода doPost() мы устанавливаем атрибут с именем добавленного в модель пользователя, после чего вызываем метод doGet(), в который передаем текущие запрос и ответ. А метод doGet() уже передает управление во вьюху, куда и отправляет объект запроса с прикрепленным именем добавленного пользователя в качестве атрибута.

Осталось подправить add.jsp, чтобы он выводил такое уведомление, если присутствует такой атрибут.

Окончательный вариант add.jsp:

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Add new user</title>
    </head>

    <body>
        <div>
            <h1>Super app!</h1>
        </div>

        <div>
            <%
                if (request.getAttribute("userName") != null) {
                    out.println("<p>User '" + request.getAttribute("userName") + "' added!</p>");
                }
            %>
            <div>
                <div>
                    <h2>Add user</h2>
                </div>

                <form method="post">
                    <label>Name:
                        <input type="text" name="name"><br />
                    </label>
                    <label>Password:
                        <input type="password" name="pass"><br />
                    </label>
                    <button type="submit">Submit</button>
                </form>
            </div>
        </div>

        <div>
            <button onclick="location.href='/'">Back to main</button>
        </div>
    </body>
</html>


Тело страницы состоит из:

div-a с шапкой;
div-контейнера для контента, в нем проверка существует ли атрибут с именем пользователя;
div с формой добавления пользователей;
ну и в конце футер с кнопкой возврата на главную страницу.

Может показаться, что слишком много div-ов, но мы их потом используем, когда добавим стилей.

Окончательный вариант list.jsp: 

<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Users</title>
    </head>

    <body>
        <div>
            <h1>Super app!</h1>
        </div>

        <div>
            <div>
                <div>
                    <h2>Users</h2>
                </div>
                <%
                    List<String> names = (List<String>) request.getAttribute("userNames");

                    if (names != null && !names.isEmpty()) {
                        out.println("<ui>");
                        for (String s : names) {
                            out.println("<li>" + s + "</li>");
                        }
                        out.println("</ui>");
                    } else out.println("<p>There are no users yet!</p>");
                %>
            </div>
        </div>

        <div>
            <button onclick="location.href='/'">Back to main</button>
        </div>
    </body>
</html>


Таким образом, у нас готово полностью рабочее веб-приложение, которое умеет хранить и добавлять пользователей, а также выводить список их имен. Осталось лишь приукрасить… :)

Добавление стилей. Используем фреймворк W3.CSS
В данный момент наше приложение рабочее, но абсолютно вырвиглазное. Поэтому добавим фон, цвет текста и кнопок, стилизуем списки, сделаем выравнивание, добавим отступы и тому подобное. Если писать стили вручную, это может занять много времени и нервов. Поэтому я предлагаю воспользоваться CSS-фреймворком W3.CSS. В нём уже есть готовые классы со стилями, осталось только расставить в нужных местах те css-классы, которые мы хотим применить.

Для того, чтобы добавить их на наши страницы, для начала подключим файл со стилями. Это можно сделать двумя способами:

пройтись по нашим страницам и в разделе head вставить прямую ссылку на файл со стилями

<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

Такой вариант подходит, если у вас постоянное подключение к интернету. Тогда при открытии ваших страниц на локальном сервере стили подтянутся из интернета.

Если же вы хотите иметь все стили у себя локально и не быть зависимым от интернет-соединения, загрузите файл со стилями и поместить его где-нибудь внутри папки web (например, web/styles/w3.css), после чего пройтись по всем нашим страничкам (index.html, add.jsp, list.jsp) и вписать внутри раздела head ссылку на этот файл со стилями

<link rel="stylesheet" href="styles/w3.css">

После этого просто пройтись по тегам и дописать те стили, которые вам понравятся. Я не буду останавливаться на этом подробно, а сразу дам свои готовые варианты трех моих файлов с раставленными классами стилей.

index.html

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Super app!</title>
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    </head>

    <body class="w3-light-grey">
        <div class="w3-container w3-blue-grey w3-opacity w3-right-align">
            <h1>Super app!</h1>
        </div>

        <div class="w3-container w3-center">
            <div class="w3-bar w3-padding-large w3-padding-24">
                <button class="w3-btn w3-hover-light-blue w3-round-large" onclick="location.href='/list'">List users</button>
                <button class="w3-btn w3-hover-green w3-round-large" onclick="location.href='/add'">Add user</button>
            </div>
        </div>
    </body>
</html>


add.jsp

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Add new user</title>
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    </head>

    <body class="w3-light-grey">
        <div class="w3-container w3-blue-grey w3-opacity w3-right-align">
            <h1>Super app!</h1>
        </div>

        <div class="w3-container w3-padding">
            <%
                if (request.getAttribute("userName") != null) {
                    out.println("<div class=\"w3-panel w3-green w3-display-container w3-card-4 w3-round\">\n" +
                            "   <span onclick=\"this.parentElement.style.display='none'\"\n" +
                            "   class=\"w3-button w3-margin-right w3-display-right w3-round-large w3-hover-green w3-border w3-border-green w3-hover-border-grey\">×</span>\n" +
                            "   <h5>User '" + request.getAttribute("userName") + "' added!</h5>\n" +
                            "</div>");
                }
            %>
            <div class="w3-card-4">
                <div class="w3-container w3-center w3-green">
                    <h2>Add user</h2>
                </div>
                <form method="post" class="w3-selection w3-light-grey w3-padding">
                    <label>Name:
                        <input type="text" name="name" class="w3-input w3-animate-input w3-border w3-round-large" style="width: 30%"><br />
                    </label>
                    <label>Password:
                        <input type="password" name="pass" class="w3-input w3-animate-input w3-border w3-round-large" style="width: 30%"><br />
                    </label>
                    <button type="submit" class="w3-btn w3-green w3-round-large w3-margin-bottom">Submit</button>
                </form>
            </div>
        </div>

        <div class="w3-container w3-grey w3-opacity w3-right-align w3-padding">
            <button class="w3-btn w3-round-large" onclick="location.href='/'">Back to main</button>
        </div>
    </body>
</html>


list.jsp

<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Users list</title>
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    </head>

    <body class="w3-light-grey">
        <div class="w3-container w3-blue-grey w3-opacity w3-right-align">
            <h1>Super app!</h1>
        </div>

        <div class="w3-container w3-center w3-margin-bottom w3-padding">
            <div class="w3-card-4">
                <div class="w3-container w3-light-blue">
                    <h2>Users</h2>
                </div>
                <%
                    List<String> names = (List<String>) request.getAttribute("userNames");

                    if (names != null && !names.isEmpty()) {
                        out.println("<ul class=\"w3-ul\">");
                        for (String s : names) {
                            out.println("<li class=\"w3-hover-sand\">" + s + "</li>");
                        }
                        out.println("</ul>");

                    } else out.println("<div class=\"w3-panel w3-red w3-display-container w3-card-4 w3-round\">\n"
+
                            "   <span onclick=\"this.parentElement.style.display='none'\"\n" +
                            "   class=\"w3-button w3-margin-right w3-display-right w3-round-large w3-hover-red w3-border w3-border-red w3-hover-border-grey\">×</span>\n" +
                            "   <h5>There are no users yet!</h5>\n" +
                            "</div>");
                %>
            </div>
        </div>

        <div class="w3-container w3-grey w3-opacity w3-right-align w3-padding">
            <button class="w3-btn w3-round-large" onclick="location.href='/'">Back to main</button>
        </div>
    </body>
</html>


Вот и все :)
Если у вас остались какие-то вопросы или есть какие-то замечания, или же наоборот что-то не получается — оставьте комментарий.

Ну и парочку скриншотов приложу что из этого всего получилось.









И напоследок

Если будет желание попрактиковаться с этим проектом — можете попробовать:

сделать сервлет и jsp для удаления пользователя и еще пару для изменения/редактирования существующего пользователя. Получится настоящее CrUD веб приложение :) на сервлетах));
заменить список (List) на работу с базой данных, чтоб добавленные пользователи не пропадали после перезапуска сервера :)
Удачи!