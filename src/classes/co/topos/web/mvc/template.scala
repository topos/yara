package co.topos.web.mvc

import java.io.{File, Writer}
import java.util.concurrent.ConcurrentHashMap
import javax.servlet._
import freemarker.cache._
import freemarker.template._
import freemarker.ext.servlet._
import freemarker.core.Environment
import freemarker.ext.beans.BeansWrapper
import scala.collection.JavaConversions._ 
import scala.collection.mutable._
import co.topos.web._

object Template {
  def apply(view: String, wc: WebContext) = {
    val t = new Template(view, TemplateConfiguration(wc.context, null), makeMap(wc, null))
    t.put("context", wc)
    t
  }
  def apply(view: String, wc: WebContext, wrapper: ObjectWrapper) = {
    val t = new Template(view, TemplateConfiguration(wc.context, wrapper), makeMap(wc, wrapper))
    t.put("context", wc)
    t
  }

  def apply(view: String, templateDir: File) = new Template(view, TemplateConfiguration(templateDir, null), HashMap[String, Object]())
  def apply(view: String, templateDir: File, wrapper: ObjectWrapper) = new Template(view, TemplateConfiguration(templateDir, wrapper), HashMap[String, Object]())

  private def makeMap(wc: WebContext, wrapper: ObjectWrapper) = {
    val REQUEST = "Request"
    val APPLICATION = "Application"
    val sc = wc.context
    HashMap[String, Object](APPLICATION -> {if (wc.hasAttribute(APPLICATION)) wc.attribute(APPLICATION) else new ServletContextHashModel(sc, wrapper)},
                            REQUEST -> new HttpRequestHashModel(wc.request, wc.response, wrapper))
  }
}

case class Template(val view: String, val config: Configuration, val model: Map[String, Object]) {
  def put(key: String, value: Object) = model.put(key, value)
  def render(out: Writer) = config.getTemplate(view + ".ftl").process(asMap(model), out)
  override def toString = {
    val w = new java.io.StringWriter
    render(w)
    w.toString
  }
}

object TemplateConfiguration extends AnyRef with Constants {
  def apply(servletContext: ServletContext, wrapper:ObjectWrapper) = {
    cache.putIfAbsent(servletContext.getRealPath(""), makeConfiguration(servletContext, wrapper)) match {
      case Some(config) => config
      case None => cache.get(servletContext.getRealPath("")).get
    }
  }

  def apply(templateDir: File, wrapper: ObjectWrapper) = {
    cache.putIfAbsent(templateDir.getCanonicalPath, makeConfiguration(templateDir, wrapper)) match {
      case Some(config) => config
      case None => cache.get(templateDir.getCanonicalPath).get
    }
  }
    
  private def makeConfiguration(servletContext: ServletContext, wrapper: ObjectWrapper) = {
    val c = new Configuration
    try { c.setCacheStorage(new freemarker.cache.MruCacheStorage(128, 256)) } catch {case _ =>}
    val loaders = List(new WebappTemplateLoader(servletContext, "template"), new WebappTemplateLoader(servletContext, "include"))
    c.setTemplateLoader(new MultiTemplateLoader(loaders.toArray))
    c.setObjectWrapper(if (null == wrapper) new BeansWrapper() else wrapper)
    c.setTemplateExceptionHandler(new TemplateExceptionHandler())
    c
  }
  
  private def makeConfiguration(templateDir: File, wrapper: ObjectWrapper) = {
    val c = new Configuration
    try { c.setCacheStorage(new freemarker.cache.MruCacheStorage(128, 256)) } catch {case _ =>}
    c.setTemplateLoader(new FileTemplateLoader(templateDir))
    c.setObjectWrapper(if (null == wrapper) new DefaultObjectWrapper() else wrapper)
    c.setTemplateExceptionHandler(new TemplateExceptionHandler())
    c.setDefaultEncoding(ENCODING)
    c.setOutputEncoding(ENCODING)
    c.setLocale(LOCALE)
    c
  }
  
  private val cache: ConcurrentMap[String, Configuration] = new ConcurrentHashMap[String, Configuration]
  
  private class TemplateExceptionHandler extends freemarker.template.TemplateExceptionHandler {
    def handleTemplateException(exc: TemplateException, env: Environment, w: java.io.Writer) = throw new TemplateException("cause: " + exc, env)
  }
}
