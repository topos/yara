package co.topos.ext

object StringExt { implicit def stringWrapper(s: String) = new StringExt(s) }

class StringExt(s: String) {
  import net.sf.junidecode.Junidecode._

  def parameterize = normalize("-")
  def toBytes(encoding: String ="UTF-8") = s.getBytes(encoding)
  def normalize(sep: String ="_") = unidecode(s.toLowerCase.trim).replaceAll("[^a-z0-9\\-_]+", sep).replaceAll("^\\" + sep + "+|\\" + sep + "$", "")

  def md5 = {
    import java.security.MessageDigest
    val md5 = MessageDigest.getInstance("MD5")
    md5.reset
    md5.update(s.getBytes("UTF-8"))
    md5.digest().map(0xFF&_).map{"%02x".format(_)}.foldLeft(""){_+_}
  }
}

