package co.topos.web.mvc

import java.io.File
import org.apache.commons.io.FileUtils._
import org.scalatest._
import org.scalatest.matchers._
import scala.collection.mutable._
import scala.collection.JavaConversions._

class TemplateSpec extends WordSpec with ShouldMatchers {
  object File { def apply(file: String) = new File(file) }

  val HELLO = "Hello, World!"
  val GDAY = "G'day, eh!"

  "Template" should {
    "substitute simple key-value pairs" in {
      writeStringToFile(File("/tmp/test1.ftl"), "${hello}-${gday}")
      val t = Template("test1", new File("/tmp"))
      t.put("hello", HELLO)
      t.put("gday", GDAY)
      val w = new java.io.StringWriter
      t.render(w)
      w.toString should be ("%s-%s".format(HELLO, GDAY))
    }
    
    "substitute list key-value pair" in {
      writeStringToFile(File("/tmp/test2.ftl"), "<#list numbers as n>${n} </#list>")
      val t = Template("test2", new File("/tmp"))
      t.put("numbers", asList(List(1, 1, 2, 3, 5, 8, 13, 21, 34)))
      val w = new java.io.StringWriter
      t.render(w)
      w.toString should be ("1 1 2 3 5 8 13 21 34 ")
    }

    "substitute map key-value pair" in {
      writeStringToFile(File("/tmp/test3.ftl"), "${map.foo}, ${map.bar}, and ${map.baz}, oh my!")
      val t = Template("test3", new File("/tmp"))
      t.put("map", asMap(HashMap("foo" -> "Apple", "bar" -> "Google", "baz" -> "Facebook")))
      val w = new java.io.StringWriter
      t.render(w)
      w.toString should be ("Apple, Google, and Facebook, oh my!")
    }

    "call and substitute from arbitrary object methods" in {
      class Foo {
	import scala.math._
	def bar(x: Double) = sin(x)
	def sin(x: Double) = math.sin(x)
      }
      writeStringToFile(File("/tmp/test4.ftl"), "${foo.bar(10.0)} == ${foo.sin(10.0)}")
      val t = Template("test4", new File("/tmp"))
      t.put("foo", new Foo)
      val w = new java.io.StringWriter
      t.render(w)
      w.toString should be ("-0.544 == -0.544")
    }
  }

}

