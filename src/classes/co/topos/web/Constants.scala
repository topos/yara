package co.topos.web

trait Constants {
  final val CONTROLLER = "c";
  final val VIEW = "v";
  final val PAGE = "p";
  final val LANG = "lang";

  final val ENCODING = "UTF-8";
  final val LOCALE = java.util.Locale.US

  final val USER_AGENT = "User-Agent"
  final val FIREFOX = "User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.12) Gecko/20101026 Firefox/3.6.12"

  def getContentType() = "text/html"
}
