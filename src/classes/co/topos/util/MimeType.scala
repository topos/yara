package co.topos.util
import java.io.File
import javax.activation.FileDataSource

object MimeType {
  def get(file: File) = { (new FileDataSource(file)).getContentType }
  def get(fileName: String) = { (new FileDataSource(fileName)).getContentType }

  final val HTML = "text/html; charset=UTF-8"
  final val PLAIN = "text/plain; charset=UTF-8"
  final val XML = "text/xml; charset=UTF-8"
  final val PDF = "application/pdf"
  final val OCTET_STREAM = "application/octet-stream"
}
