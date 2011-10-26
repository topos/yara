package co.topos.ext

import org.scalatest._
import org.scalatest.matchers._
import StringExt._

class StringExtSpec extends WordSpec with ShouldMatchers {
  "StringExt" should {
    "parameterize" in {
      "a b c".parameterize should be ("a-b-c")
      "a b c-".parameterize should be ("a-b-c")
      "-a b c".parameterize should be ("a-b-c")
      "-a b c-".parameterize should be ("a-b-c")
      "-a b c-".parameterize should be ("a-b-c")
      "--a b   c-  ".parameterize should be ("a-b-c")
      "- -  a b   c-  ".parameterize should be ("a-b-c")
      "http://ecf.nysd.uscourts.gov/foo/bar/baz".parameterize should be ("http-ecf-nysd-uscourts-gov-foo-bar-baz")
    }
  }

  "StringExt" should {
    "md5sum" in {
      "abc".md5 should be ("900150983cd24fb0d6963f7d28e17f72")
    }
  }
}
