local DeliverIdDetect = function(id)
  if id >= bo2.eNpcFunc_Deliver1 or id <= bo2.eNpcFunc_DeliverMAX then
    local excel = bo2.gv_npc_func:find(id)
    if excel ~= nil and excel.datas.size == 2 then
      if sys.check(bo2.player) then
        local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
        if player_lv < excel.datas[1] then
          return false, excel.datas[0]
        else
          return true, excel.datas[0]
        end
      end
    elseif excel ~= nil then
      return true, excel.datas[0]
    else
      return true, nil
    end
  end
  return true
end
function on_deliver(btn)
  local id = btn.svar.id
  if id == 0 then
    return
  end
  ui_npcfunc.ui_deliver.set_id(id)
  ui_npcfunc.ui_deliver.on_deliver_click()
  w_main.visible = false
end
function on_flicker_mouse(btn, msg)
  if msg == ui.mouse_inner then
    btn:search("btn_flicker").suspended = false
  elseif msg == ui.mouse_outer then
    btn:search("btn_flicker").suspended = true
  end
end
function on_visible(c, vis)
  if vis == true then
    local scn_btn
    for i = bo2.eNpcFunc_Deliver1, bo2.eNpcFunc_DeliverMAX do
      local b, id = DeliverIdDetect(i)
      if id then
        local scn_id = bo2.gv_deliver_list:find(id).scn_id
        local btn = w_btns:search(scn_id)
        if btn then
          if scn_id == bo2.player:get_flag_objmem(bo2.eFlagObjMemory_ScnExcelID) then
            btn.visible = true
            btn:search("button").enable = false
            btn:search("button").svar.id = 0
            scn_btn = btn
            btn:search("select").visible = false
            if w_btns:search("line_" .. scn_id) then
              w_btns:search("line_" .. scn_id).visible = true
            end
          else
            btn.visible = true
            if b then
              btn:search("button").enable = true
              btn:search("button").svar.id = i
              btn:search("select").visible = true
            else
              btn:search("button").enable = false
              btn:search("select").visible = false
              btn:search("button").svar.id = 0
            end
            if w_btns:search("line_" .. scn_id) then
              w_btns:search("line_" .. scn_id).visible = false
            end
          end
        end
      end
    end
  end
  ui_handson_teach.test_complate_deliver(vis)
end
function on_init()
end
