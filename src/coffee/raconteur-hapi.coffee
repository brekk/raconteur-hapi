_ = require 'lodash'
raconteur = require 'raconteur'
telepath = raconteur.telepath
debug = require('debug')('raconteur:hapi')

module.exports = {
    module: {
        compileMode: 'async'
        compile: (filePath, content={}, callback)->
            unless _.isFunction callback # we won't rethrow because there's nothing to throw to
                throw new TypeError 'Expected callback to be a function'
            issue = null
            unless _.isString filePath
                issue = new TypeError "Expected filePath to be a string."
            if !content.post?
                issue = new Error "Expected content.post to be set."
            if issue?
                callback issue
                return
            chain = telepath.chain()
            if content.file or !content.raw?
                debug "using file mode"
                chain = chain.file()
            else
                debug "using raw mode"
                chain = chain.raw()
            if content.sugar? and content.sugar
                debug "using sugar mode"
                chain = chain.sugar()
            if content.yaml? and content.yaml
                debug "using yaml mode"
                chain = chain.yaml()
            if content.locals?
                _.each content.locals, (value, key)->
                    debug "adding local:", key
                    content.locals[key] = value
            chain.template filePath, content
                 .post content.post, content
                 .ready (e, out)->
                    if e?
                        callback e
                        return
                    callback null, out[0]
    }
}