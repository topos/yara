package co.topos.conf

import org.scalatest._
import org.scalatest.matchers._

class ConfigurationSpec extends WordSpec with ShouldMatchers {
  import java.io._

  "ConfigurationParser" should {
    "have paths, key/value pairs" in {
      val c = (new ConfigurationParser).parse(new StringReader("[abc]\na=apple\nb=bat"))
      c.get("abc", "a") should be ("apple")
      c.get("abc", "b") should be ("bat")
    }

    "throw Exception when key/value doesn't exist" in {
      val c = (new ConfigurationParser).parse(new StringReader("[abc]\na=apple\nb=bat"))
      c.get("abc", "a") should be ("apple")
      c.get("abc", "b") should be ("bat")
      intercept[NoSuchElementException] { c.get("boojum", "for_it_was_a_boojum") }
    }
  }

  "Configuration" should {
    "handle quoted strings" in {
      val c = (new ConfigurationParser).parse(new StringReader("[abc]\n foo = \"bar\"\n  baz =\" abc  123   \"\n uv =\"  \"abc\"   \""))
      c.get("abc/foo") should be ("bar")
      c.get("abc/baz") should be (" abc  123   ")
      c.get("abc/uv") should be ("  \"abc\"   ")
    }

    "have non-zero paths and elements" in {
      val c = Configuration("web.conf")
      c.assignments.size should be >= 1
      c.headers.size should be >= 1
    }
  }
}
