local sel_id, scn_id
function set_id(id)
  ui.log("sel_id")
  local excel = bo2.gv_npc_func:find(id)
  if excel == nil then
    ui.log("set_id excel is nil")
    return
  end
  local deliver_excel = bo2.gv_deliver_list:find(excel.datas[0])
  ui.log("excel.datas[0] %s", excel.datas[0])
  if deliver_excel == nil then
    ui.log("set_id deliver_excel is nil")
    return
  end
  sel_id = deliver_excel.id
  w_main:search("box").mtf = deliver_excel.des
end
function on_deliver_click(btn)
  ui.log("sel_id = %s", sel_id)
  if sel_id == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.deliver_id, sel_id)
  v:set(L("flag"), 1)
  bo2.send_variant(packet.eCTS_UI_Deliver, v)
  w_main.visible = false
end
