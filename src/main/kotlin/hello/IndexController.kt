package hello

import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.MediaType

@Controller("/")
class IndexController {

    @Get(produces = [MediaType.TEXT_HTML])
    fun index(): String {
        return "<h2>Hello Service with Envoy!</h2><strong>(Sidecar Pattern)</strong>"
    }

}