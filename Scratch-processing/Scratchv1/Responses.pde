public class PollResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/text");
    PrintWriter out = response.getWriter();

    // println(request);
    
    // Map values for slightly different scratch coordinate system.
    float mappedBotX = botX - (480 / 2);
    float mappedBotY = -1 * (botY - (360 / 2));
    float mappedBotR = botR + 90;
    float mappedbotT = botT;
    out.println("botX " + mappedBotX + "\n");
    out.println("botY " + mappedBotY + "\n");
    out.println("botR " + mappedBotR + "\n");
    out.println("botT " + mappedbotT + "\n");
  }
}


public class GreetResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    println(request);
    
    sayHello = true;

    out.println(simpleHtmlPage("greet"));
  }
}

public class ScratchPositionResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    println("ScratchPositionResponse");

    String strPosn = request.getPathInfo().split("/")[1];
    String[] aryPosn = strPosn.split(",");

    printArray(aryPosn);

    scratchX = Float.parseFloat(aryPosn[0]);
    scratchY = Float.parseFloat(aryPosn[1]);
    scratchR = Float.parseFloat(aryPosn[2]);
    scratchC = Float.parseFloat(aryPosn[3]);
    
    //scratchX = Float.parseFloat(strX);
    
    //println(scratchX);
    
    out.println(simpleHtmlPage("scratchPosition"));
  }
}

public class ScratchXResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String strX = request.getPathInfo().split("/")[1];
    scratchX = Float.parseFloat(strX);
    
    //println(scratchX);
    
    out.println(simpleHtmlPage("scratchX"));
  }
}

public class ScratchYResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String strY = request.getPathInfo().split("/")[1];
    scratchY = Float.parseFloat(strY);
    
    //println(scratchY);
    
    out.println(simpleHtmlPage("scratchY"));
  }
}
public class ScratchRResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String strR = request.getPathInfo().split("/")[1];
    scratchR = Float.parseFloat(strR);
    
    
    //println(scratchR);
    
    out.println(simpleHtmlPage("scratchR"));
  }
}
public class ScratchCResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String strC = request.getPathInfo().split("/")[1];
    scratchC = Float.parseFloat(strC);
    
    
   // println(scratchC);
    
    out.println(simpleHtmlPage("scratchC"));
  }
}
public class ScratchstartResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String strstart = request.getPathInfo().split("/")[1];
    scratchstart = Float.parseFloat(strstart);
    
    
   // println(scratchC);
    
    out.println(simpleHtmlPage("scratchC"));
  }
}
public class botstartResponse extends HttpServlet {

  @Override public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();

    String bstart = request.getPathInfo().split("/")[1];
    botstart = Float.parseFloat(bstart);
    
    
   // println(scratchC);
    
    out.println(simpleHtmlPage("scratchC"));
  }
}
String simpleHtmlPage(String title) {
  return "<!DOCTYPE html>" + "\n"
    + "<html>\n"
    + "<head><title>" + title + "</title></head>\n"
    + "<body>\n"
    + "<h1>" + title + "</h1>\n"
    + "</body></html>";
}