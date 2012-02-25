package co.topos.web

abstract class Controller(val context: WebContext) {
  val request = context.request
  val response = context.response

  def isPost = request.getMethod == "POST"
  def isGet = request.getMethod == "GET"
  def isPut = request.getMethod == "PUT"

  def service(): Unit
}
