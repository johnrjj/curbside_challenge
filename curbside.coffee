# Curbside Challenge - John J - 2015
_ = require 'lodash'
rp = require 'request-promise'
q = require 'bluebird' 
chalk = require 'chalk'
baseUrl = 'http://challenge.shopcurbside.com/'

getToken = -> rp baseUrl + 'get-session'

getNode = (id, token) ->
  requestOptions = getRequestOptions(id, token)
  rp requestOptions

getRequestOptions = (id, token) ->
  url: baseUrl + id
  json: true
  headers: 'Session': token

getChildNodes = (id) ->
  new q((resolve) ->
    getToken().then (token) ->
      getNode(id, token).then (node) ->
        # If it's a leaf node, resolve promise, bubble up
        resolve node.secret if node.secret
        # The API likes to give us some badly cased JSON sometimes :P
        unless node.next
          raw = JSON.stringify(node).toLowerCase()
          node = JSON.parse(raw)
        # Dump single child string into array for consistency
        node.next = [ node.next ] if _.isString(node.next)
        # Map each 'child' to a promise, and recurse
        promises = _.map(node.next, getChildNodes)
        q.all(promises).then resolve
)

start = ->
  getChildNodes('start').then (result) ->
    secretMessage = _.flattenDeep(result).join('')
    console.log chalk.bgGreen(secretMessage)

start()