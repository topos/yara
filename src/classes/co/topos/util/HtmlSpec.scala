package co.topos.util

import org.scalatest._
import org.scalatest.matchers._

class HtmlSpec extends WordSpec with ShouldMatchers {
  "Html transform" should {
    "replace \u2014 with &#x2014" in {
      Html.encode("foo\u2014bar") should be ("foo&#x2014;bar")
    }
  }
}
