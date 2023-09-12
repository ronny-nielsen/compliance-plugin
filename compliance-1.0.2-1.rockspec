package = "compliance"
version = "1.0.2-1"

source = {
    url = "*** please add URL for source tarball, zip or repository here ***"
}

description = {
    homepage = "*** please enter project homepage ***",
    license = "*** please specify a license ***"
}

dependencies = {
    "luasocket >= 3.1",
    "luajson >= 1.3"
}

build = {
    type = "builtin",
    modules = {
        handler = "kong/plugin/handler.lua",
        schema = "kong/plugin/schema.lua"
    }
}