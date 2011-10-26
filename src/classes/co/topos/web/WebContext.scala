package co.topos.web

import java.util.List
import java.util.Locale
import javax.servlet._
import javax.servlet.http._
import org.apache.commons.lang.StringUtils

object WebContext {
  def apply(request: HttpServletRequest, response: HttpServletResponse, context: ServletContext) =  new WebContext(request, response, context)
}

class WebContext(val request: HttpServletRequest, val response: HttpServletResponse, val context: ServletContext) extends AnyRef with Constants
{
  def webApp = {
    val app = request.getContextPath() match {
      case "" => null
      case "/" => null
      case _ => StringUtils.removeStart(request.getContextPath, "/")
    }
    app
  }
  def isWebApp = !org.apache.commons.lang.StringUtils.isBlank(webApp)

  def controller = if (hasController) request.getParameter(CONTROLLER) else restPath(0)
  def hasController = !org.apache.commons.lang.StringUtils.isBlank(request.getParameter(CONTROLLER))

  def attribute(key: String) = context.getAttribute(key)
  def hasAttribute(key: String) = context.getAttribute(key) != null || context.getAttribute(key) != ""
  def setAttribute(key: String, value: Object) = context.setAttribute(key, value)

  def restPath = request.getPathInfo.split("/").tail

  def requestUrl = {
    val url = request.getRequestURL
    if (request.getQueryString != null) url.append("?").append(request.getQueryString)
    url.toString
  }

  def realPath = context.getRealPath("")
}
