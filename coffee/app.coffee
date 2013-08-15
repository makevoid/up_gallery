# confs

# PATH = "issues/5"
PATH = "issues_linux/5"
SIZE = 11 -1 # as it's zero based


# utils

llog = (log) ->
  debug = document.querySelector ".debug"
  debug.innerHTML += "#{log}<br>"

defer = (fn) ->
  setTimeout fn, 0

class Gallery
  constructor:  ->
    @idx = 0 # current index
    @images = []
    @window = new Window(this)
    this.fill_window()
    this.bind_swipe()

  # init

  fill_window: ->


  bind_swipe: ->
    img = document.querySelector ".main img[data-id='0']"
    img.addEventListener "touchend", this.handle_swipe.bind this


  # handlers

  handle_swipe: ->
    console.log "swipe"
    llog "swipe"
    this.next()

  handle_keyboard: (evt) ->
    this.prev() if evt.keyCode == 37
    this.next() if evt.keyCode == 39

  handle_thumbs_click: (evt) ->
    id = evt.target.dataset.id
    this.go_to parseInt(id)

  # actions

  next: ->
    this.go_to @idx+1

  prev: ->
    this.go_to @idx-1

  go_to: (idx) ->
    return if @idx == idx
    return if idx < 0
    return if idx > SIZE
    console.log "switch to", idx+1
    # sanitize idx

    direction = "forward"

    if this.nearby(idx)
      @window.push_and_slide(idx)
    else
      @window.replace_window(idx)

    # async? (called inside window)
    @idx = idx

  # utils

  nearby: (idx) ->
    idx == @idx-1 || idx == @idx+1

class Window
  images_dir: PATH

  constructor: (@gallery) ->

  # replace

  replace_window: (idx) ->
    images = document.querySelectorAll ".main img"
    for img in images
      img.remove()

    img = document.createElement "img"
    img.draggable = true
    img.dataset.id = idx
    img.src = "/#{this.images_dir}/#{this.pad idx+1}.jpg"

    this.gallery_elem().appendChild img
    img.style.opacity = 1

    img.style.webkitTransform = "translate3d(0, 0, 0)"

  # push_and_slide

  push_and_slide: (idx) ->
    this.push_image idx

  push_image: (idx) ->
    direction = this.direction idx

    img = document.createElement "img"
    img.draggable = true
    img.dataset.id = idx
    img.src = "/#{this.images_dir}/#{this.pad idx+1}.jpg"

    if direction == "next"
      this.gallery_elem().appendChild img
      img.style.opacity = 1
      # place on the right
      img.style.webkitTransform = "translate3d(100%, 0, 0)"
    else
      this.gallery_elem().insertBefore img
      img.style.opacity = 1
      # place on the left
      img.style.webkitTransform = "translate3d(-100%, 0, 0)"

    this.slide direction, idx

  deferred_slide: (idx, percent) ->
    defer ->
      img = document.querySelector ".main img[data-id='#{idx}']"
      img.style.webkitTransform = "translate3d(#{percent}%, 0, 0)"

  slide: (direction, idx) ->
    next_id = if direction == "next" then idx-1 else idx+1
    position = if direction == "next" then -100 else 100
    this.deferred_slide next_id, position

    this.deferred_slide idx, 0

    this.remove_image next_id, direction

  remove_func: (idx) ->
    img = document.querySelector ".main img[data-id='#{idx}']"
    img.remove()
    console.log "removed #{idx}", event

  remove_image: (idx) ->
    # images = document.querySelectorAll ".main img"
    # for img in images
    #   img.removeEventListener "webkitTransitionEnd", => this.remove_func(idx)
    #   console.log "remove listeners"

    # idx = @gallery.idx


    console.log "will remove #{idx}"

    # this.delayed_remove remove_func
    img = document.querySelector ".main img"
    img.addEventListener "webkitTransitionEnd", => this.remove_func(idx)

  # private

  webkit_is_supported: ->
    true

  delayed_remove: (func) ->
    if this.webkit_is_supported()
      img = document.querySelector ".main img"
      img.addEventListener "webkitTransitionEnd", =>
        func()
    else
      setTimeout =>
         func()
      , 700

  gallery_elem: ->
    document.querySelector ".main"

  direction: (idx) ->
    if idx > @gallery.idx then "next" else "prev"

  pad: (num) ->
    s = "0" + num
    s.substr s.length-2


# main


domready ->

  gallery = new Gallery()
  window.gallery = gallery

  window.addEventListener "keydown", gallery.handle_keyboard.bind gallery

  thumbs = document.querySelectorAll ".thumbs img"
  for thumb in thumbs
    thumb.addEventListener "click", gallery.handle_thumbs_click.bind gallery

  prev = document.querySelector ".main .prev"
  prev.addEventListener "click", gallery.prev.bind gallery
  next = document.querySelector ".main .next"
  next.addEventListener "click", gallery.next.bind gallery

#

# failed attempt in using the low level api
# img = document.querySelector("img"); evt = new WebKitTransitionEvent("asd"); evt.cancelable = true; evt.currentTarget = img; evt.propertyName = "-webkit-transform"; evt.eventPhase = 2; evt.initEvent("asd"); evt