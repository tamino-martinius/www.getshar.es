##############
# Extensions #
##############

# String

String::startsWith = (m) -> @match("^#{m}")?
String::endsWith   = (m) -> @match("#{m}$")?
String::contains   = (m) -> @match("#{m}")?
String::data       = -> if @toString() is '' then null else @toString()
String::capitalize = -> if @length > 0 then @[0].toUpperCase() + @slice(1) else ""
String::trim       = (c = '\\s') -> @replace(new RegExp("^[#{c}]+|[#{c}]+$", 'g'), '')
String::rtrim      = (c = '\\s') -> @replace(new RegExp(         "[#{c}]+$", 'g'), '')
String::ltrim      = (c = '\\s') -> @replace(new RegExp("^[#{c}]+"         , 'g'), '')
String::dasherize  = (c = '_')-> @replace(new RegExp('[A-Z]', 'g'), (m) -> "[#{c}]#{m.toLowerCase()}").trim(c)
String::classify   = -> @replace(new RegExp('_[a-z]', 'g'), (m) -> m.toUpperCase().trim('_')).capitalize()
String::tsplit     = (c = '\\s') -> @trim(c).split(new RegExp("[#{c}]", 'g'))
String::toHash     = (groupSep = '?&', sep = '=') ->
  _.reduce @tsplit(groupSep), (obj, q) ->
    [key, value] = q.split(sep)
    obj[key] = value if key?
    obj
  , {}


# Number

functionNames = ["ceil", "floor", "round"]

for functionName in functionNames
  do (functionName) ->
    Number::[functionName] = (precision = 0) ->
      factor = Math.pow(10, precision)
      Math[functionName](@ * factor) / factor


# Array

functionNames = ["sample"]

for functionName in functionNames
  do (functionName) ->
    Array::[functionName] = (args...) ->
      args.unshift(@)
      _[functionName].apply(_, args)


#########
# Views #
#########

getCountHtml = (count) ->
  count = count.toFixed 0 if count.toFixed?
  index = count.length
  while index > 3
    index -= 3
    count = count.substr(0, index) + ',' + count.substr(index)
  count

networkNames = [
  'twitter'
  'facebook'
  'pinterest'
  'linkedin'
  # 'delicious'
  'reddit'
  'googleplus'
  'flattr'
  'stumbleupon'
  'buffer'
  'vk'
  'pocket'
  # 'weibo'
  'xing'
]
networks = {}

Meteor.startup () ->
  settings =
    root: $('DummyNode')
    autoInit: false

  for name in networkNames
    networks[name] = new GetShare $.extend(settings, {network: name})

total = 0

addTotal = (count) ->
  total += count
  setCount $('.total-count'), total

setCount = ($elems, count) ->
  if $elems.length is 1
    $elems.addClass 'active'
    $elems.html(getCountHtml(count))
  else
    setCount($(elem), count) for elem in $elems

Template.body.events
  'change input[type=url]': (e) ->
    url = $('input[type=url]').val()
    $('input[type=url]').val("http://#{url}") if not url.contains('://')
  'click .blk': (e) ->
    $(e.currentTarget).find('.more').toggleClass 'active'
  'submit form': (e) ->
    e.preventDefault()

    total = 0
    setCount($('.count, .total-count'), 0)
    $('.more, .count, .total-count').removeClass 'active'

    window.VK.Share.count = (a, count) ->
      addTotal count
      setCount $('.blk.vk .count'), count
    for name in networkNames
      networks[name].setUrl $('input[type=url]').val(), (elem) ->
        addTotal @counter.count
        if @network isnt 'vk'
          setCount $(".blk.#{@network} .count"), @counter.count
        if @network is 'facebook'
          $counts = $('.blk.facebook .more .count')
          setCount $counts.eq(0), elem[0].comment_count
          setCount $counts.eq(1), elem[0].like_count
          setCount $counts.eq(2), elem[0].share_count
        if @network is 'reddit'
          score = ups = downs = 0
          for listing in elem.data.children
            ups += listing.data.ups
            downs += listing.data.downs
            score += listing.data.score
          $counts = $('.blk.reddit .more .count')
          setCount $counts.eq(0), ups
          setCount $counts.eq(1), downs
          setCount $counts.eq(2), score
    false
