package co.topos.util

import org.scalatest._
import org.scalatest.matchers._

class BlobSpec extends WordSpec with ShouldMatchers {
  "Blob indexOf/contains" should {
    "be non-zero/true" in {
      val blob = Array[Byte](0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF)
      Blob.indexOf(blob, Array[Byte](0x0, 0x1, 0x2, 0x3)) should be (0)
      Blob.contains(blob, Array[Byte](0x0, 0x1, 0x2, 0x3)) should be (true)
      Blob.indexOf(blob, Array[Byte](0x4, 0x5, 0x6)) should be (4)
      Blob.contains(blob, Array[Byte](0x4, 0x5, 0x6)) should be (true)
      Blob.indexOf(blob, Array[Byte](0xA, 0xB, 0xC, 0xD, 0xE, 0xF)) should be (10)
      Blob.contains(blob, Array[Byte](0xA, 0xB, 0xC, 0xD, 0xE, 0xF)) should be (true)
    }
  }

  "BlobMatcher not indexOf/contains" should {
    "be zero" in {
      val blob = Array[Byte](0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF)
      Blob.indexOf(blob, Array[Byte](0x0, 0xA, 0x2, 0x3)) should be (-1)
      Blob.indexOf(blob, Array[Byte](0x4, 0x5, 0x6, 0xF)) should be (-1)
      Blob.indexOf(blob, Array[Byte](0xA, 0xC, 0xB, 0xC, 0xD, 0xE, 0xF)) should be (-1)
    }
  }
}
