package co.topos.web

import java.io.File
import java.lang._
import java.lang.reflect._
import co.topos.conf._

object Resolver {
  def webAppController(controller: String, context: WebContext) = makeController(controller, context, Configuration(new File(context.realPath + "/WEB-INF/controller.conf")))
  def controller(controller: String, context: WebContext) = makeController(controller, context, Configuration("controller.conf"))

  private def makeController(controller: String, context: WebContext, config: Configuration) =  {
    val c = Class.forName(config.get("controller", controller))
    val cons = c.getConstructor(classOf[WebContext])
    cons.newInstance(context).asInstanceOf[Controller]
  }
}
