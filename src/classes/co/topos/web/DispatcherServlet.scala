package co.topos.web

import javax.servlet._
import javax.servlet.http._
import co.topos.web._
import co.topos.util._

class DispatcherServlet extends HttpServlet {
  override def doGet(req: HttpServletRequest, res: HttpServletResponse) = dispatch(req, res)
  override def doPost(req: HttpServletRequest, res: HttpServletResponse) = dispatch(req, res)

  private def dispatch(req: HttpServletRequest, res: HttpServletResponse): Unit = controller(WebContext(req, res, getServletContext())).service

  private def controller(context: WebContext) = {
    if (context.isWebApp) 
      Resolver.webAppController(context.controller, context) 
    else
      Resolver.controller(context.controller, context)
  }
}
