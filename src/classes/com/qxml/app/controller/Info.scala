package com.qxml.app.controller

import co.topos.web._
import co.topos.web.mvc._
import co.topos.util._
import scala.collection.JavaConversions._

class Info(context: WebContext) extends Controller(context: WebContext) {
  def service = {
    response.setContentType(MimeType.PLAIN)
    try {
      context.restPath(1) match {
        case "hello" => response.getWriter.print("Hello, World!")
        case "template" => {
          import java.io.File
          val t = Template("info", new File(context.realPath + "/template"))
          t.put("greetings", "Hello, World! (generated by a template)")
          t.render(context.response.getWriter)
        }
        case x => response.getWriter.print(x)
      }
    } catch {
      case x => response.getWriter.print("i dunno: [" + x.getStackTrace.mkString("\n") + "]")
    }
    response.getWriter.flush
  }
}
