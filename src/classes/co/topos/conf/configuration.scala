package co.topos.conf

import java.io.{File, FileInputStream}
import scala.collection.mutable._

object Configuration {
  def apply(res: String): Configuration = { 
    import co.topos.ext.StringExt._
    if (!cache.contains(res.md5)) cache.putIfAbsent(res.md5, ConfigurationParser(res))
    cache.get(res.md5)
  }
  def apply(conf: File): Configuration =  { 
    if (!cache.contains(conf.getCanonicalPath)) cache.putIfAbsent(conf.getCanonicalPath, ConfigurationParser(conf))
    cache.get(conf.getCanonicalPath)
  }
  def apply(headers: Set[String], assignments: Map[String, String]) = new Configuration(headers, assignments)

  import java.util.concurrent.ConcurrentHashMap
  import scala.collection.JavaConversions._ 

  private val cache = new ConcurrentHashMap[String, Configuration]
}

class Configuration(val headers: Set[String], val assignments: Map[String, String]) {
  def get(hdrkey: String): String = {
    val nodes = hdrkey.split("/")
    search(nodes.init.mkString("/"), nodes.last)
  }
  def get(header: String, key: String) = search(header, key)
  def has(header: String, key: String) = get(header, key) != null

  private def search(header: String, key: String): String = {
    if (header == null || key == null) return null
    var nodes = header.split("/")
    for (i <- 0 to nodes.length - 1) {
      val pkey = (nodes.dropRight(i) :+ key).mkString("/")
      if (assignments(pkey) != null) return assignments(pkey)
    }
    return null
  }
}

import org.apache.commons.io.{IOUtils, FileUtils}

object ConfigurationParser {
  def apply(res: String): Configuration = {
    val s = resource(res).openStream
    return try {
      (new ConfigurationParser).parse(s)
    } finally {
      s.close
    }
  }

  def apply(conf: File): Configuration = {
    val s = new FileInputStream(conf)
    try {
      return (new ConfigurationParser).parse(s)
    } finally {
      s.close
    }
  }

  import java.net.URL
  def resource(res: String): URL = if (res.startsWith("/")) getClass.getResource(res) else getClass.getResource("/" + res)
}

class ConfigurationParser {
  import java.io.{InputStream, Reader}
  import java.nio.charset.Charset
  import org.apache.commons.io.input.ReaderInputStream 

  def parse(conf: Reader): Configuration = parse(new ReaderInputStream(conf, Charset.forName("UTF-8")))

  def parse(conf: InputStream): Configuration = {
    var prefix = ""

    import scala.io.BufferedSource

    (new BufferedSource(conf)("utf-8")).getLines.foreach{
      l => 
        l match {
          case header(path) => 
            prefix = path.trim
            headers.add(path.trim)
          case assignment(eq) =>
            val pair = eq.split("=",2).map(_.trim)
            assignments += prefix + "/" + pair(0) -> stripQuotes(pair(1))
          case _ =>
        }
    }

    Configuration(headers, assignments)
  }

  private def stripQuotes(qstr: String): String = {
    val QSTR = """^"(.*)"$""".r
    qstr match {
      case QSTR(str) =>
        return str
      case _ =>
        return qstr
    }
  }

  private val headers = HashSet.empty[String]
  private val assignments = HashMap.empty[String, String]

  private val header = """^\[(.*)\]$""".r
  private val assignment = """^(.+=.+)$""".r
}
