package co.topos.util

object Blob {
  def indexOf(blob: Array[Byte], seq: Array[Byte]): Long = {
    val FAILURE = makeFailure(seq)

    var j = 0;
    for (i <- 0 until blob.length) {
      while (j > 0 && seq(j) != blob(i))
        j = FAILURE(j - 1)

      if (seq(j) == blob(i))
        j += 1

      if (j == seq.length)
        return i - seq.length + 1
    }

    -1L
  }

  def contains(blob: Array[Byte], seq: Array[Byte]): Boolean = { indexOf(blob, seq) != -1L }

  private def makeFailure(seq: Array[Byte]): Array[Byte] = {
    var failure = new Array[Byte](seq.length)

    var j = 0
    for (i <- 1 until seq.length) {
      while (j > 0 && seq(j) != seq(i))
        j = failure(j - 1)

      if (seq(j) == seq(i))
        j += 1

      failure(i) = j.toByte
    }

    failure
  }
}
