local cd_get = function()
  local skill_id = w_tudun.svar.skill_id
  local info = ui.skill_find(skill_id)
  if info == nil then
    return nil
  end
  if info.cooldown == 0 then
    return nil
  end
  return info
end
local function cd_update()
  local info = cd_get()
  if info == nil then
    w_btn_trans.visible = true
    w_cd_text.visible = false
    return
  end
  w_btn_trans.visible = false
  w_cd_text.visible = true
  local cd = info.cooldown
  local hour = math.floor(cd / 3600)
  local minute = math.floor(math.mod(cd, 3600) / 60)
  local second = math.mod(math.mod(cd, 3600), 60)
  local time_t
  if hour ~= 0 then
    time_t = ui_widget.merge_mtf({left_h = hour}, ui.get_text("skill|tip_hour"))
  end
  if minute ~= 0 then
    time_t = time_t .. ui_widget.merge_mtf({left_m = minute}, ui.get_text("skill|tip_minute"))
  end
  time_t = time_t .. ui_widget.merge_mtf({left_s = second}, ui.get_text("skill|tip_second"))
  w_cd_text.mtf = sys.format([[
<a+:m><c+:FF0000>%s
%s<c-><space:1><a->]], ui.get_text("tool|left_cooldown_time"), time_t)
end
function on_visible(ctrl, vis)
  if not vis then
    return
  end
  local vip = 100
  local level = 100
  local player = bo2.player
  if player ~= nil then
    if player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours) ~= 0 then
      vip = player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
    else
      vip = 0
    end
    level = player:get_atb(bo2.eAtb_Level)
  end
  local function is_visible(excel)
    if excel.level > 0 and level < excel.level then
      return false
    end
    if 0 < excel.vip and vip < excel.vip then
      return false
    end
    if excel.scn_id == 891 then
      return bo2.is_in_guild() ~= L("0")
    end
    return true
  end
  w_list:item_clear()
  w_btn_trans.enable = false
  local tudun_table = bo2.gv_scn_tudun
  local c = tudun_table.size
  for i = 0, c - 1 do
    local excel = tudun_table:get(i)
    if is_visible(excel) then
      local item = w_list:item_append()
      item:load_style("$frame/qbar/tudun.xml", "list_item")
      item:search("name").text = excel.name
      item:search("money").money = excel.money
      item.svar.tudun_excel = excel
    end
  end
  cd_update()
end
local item_check_hover = function(item)
  local vis = item.selected or item.inner_hover
  item:search("hi").visible = vis
end
function on_item_sel(item, sel)
  item_check_hover(item)
  w_btn_trans.enable = true
end
local function item_trans(item)
  if cd_get() ~= nil then
    return
  end
  local excel = item.svar.tudun_excel
  local skill_id = w_tudun.svar.skill_id
  w_tudun.visible = false
  local do_trans = true
  local qtext
  if excel.money > 0 then
    local player = bo2.player
    local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    if money < excel.money then
      qtext = ui_widget.merge_mtf({
        target = excel.name,
        money = "<bm:" .. excel.money .. ">"
      }, ui.get_text("qbar|tudun_q3"))
      do_trans = false
    else
      qtext = ui_widget.merge_mtf({
        target = excel.name,
        money = "<bm:" .. excel.money .. ">"
      }, ui.get_text("qbar|tudun_q2"))
    end
  else
    qtext = ui_widget.merge_mtf({
      target = excel.name
    }, ui.get_text("qbar|tudun_q1"))
  end
  ui_widget.ui_msg_box.show_common({
    text = qtext,
    btn_confirm = true,
    btn_cancel = do_trans,
    callback = function(msg)
      if msg.result == 1 and do_trans then
        bo2.use_skill_var(skill_id, excel.id)
      end
    end
  })
end
function on_item_mouse(item, msg)
  if msg == ui.mouse_inner or msg == ui.mouse_outer then
    item_check_hover(item)
  elseif msg == ui.mouse_lbutton_dbl then
    item_trans(item)
  end
end
function on_trans_click(btn)
  local item = w_list.item_sel
  if item == nil then
    return
  end
  item_trans(item)
end
function show(skill_id)
  w_tudun.svar.skill_id = skill_id
  w_tudun.visible = not w_tudun.visible
end
function on_timer(t)
  cd_update()
end
