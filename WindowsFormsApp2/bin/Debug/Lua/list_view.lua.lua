local do_update = function(w)
end
local cs_do_update = SHARED("ui_widget.ui_list_view.do_update")
local function post_update(w)
  w:insert_post_invoke(do_update, cs_do_update)
end
function on_init(w)
  local d = {}
  w.svar.list_view_data = d
  local style, item = cfg:split("?")
  d.style = style
  d.item = item
end
function insert(w, idx)
end
