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
