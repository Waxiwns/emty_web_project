package app.servlets;

import app.entities.User;
import app.model.Model;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class AddServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
//        PrintWriter printWriter = resp.getWriter();
//        printWriter.println("Method GET from AddServlet");
        RequestDispatcher requestDispatcher = req.getRequestDispatcher("pages/add.jsp");
        requestDispatcher.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String password = req.getParameter("pass");
        Model model = Model.getInstance();
        boolean noUser = !model.list().contains(name);

        if (noUser) {
            User user = new User(name, password);
            model.add(user);
        }

        req.setAttribute("userName", name);
        req.setAttribute("noUser", noUser);
        doGet(req, resp);
    }
}
