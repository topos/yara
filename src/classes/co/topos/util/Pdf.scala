package co.topos.util

object Pdf {
  import java.io.{OutputStream, StringBufferInputStream}

  def isValid(pdf: Array[Byte]): Boolean = {
    import com.itextpdf.text.pdf.PdfReader
    try { new PdfReader(pdf) } catch { case _ => return false }
    true
  }

  def fo2Pdf(xslFo: String, pdf: OutputStream): Unit = {
    import javax.xml.transform._
    import javax.xml.transform.stream._
    import javax.xml.transform.sax._
    import org.apache.fop.apps._
    import co.topos.util.MimeType

    val factory = FopFactory.newInstance()
    val fop = factory.newFop(MimeType.PDF, factory.newFOUserAgent(), pdf)
    val src = new StreamSource(new StringBufferInputStream(xslFo), "UTF-8")
    val res = new SAXResult(fop.getDefaultHandler())
    val tfactory = TransformerFactory.newInstance()
    val transformer = tfactory.newTransformer()

    transformer.transform(src, res)
  }
}
