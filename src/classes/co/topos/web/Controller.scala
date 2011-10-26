package co.topos.web

abstract class Controller(val context: WebContext) {
  val request = context.request
  val response = context.response

  def service(): Unit
}
