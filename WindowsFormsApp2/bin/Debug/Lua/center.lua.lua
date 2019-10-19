local findPopo = function(ctrl)
  for i, p in ipairs(m_popo_sets) do
    if p.centerCtrl == ctrl then
      return p
    end
  end
end
local function onClick(btn)
  local popo = findPopo(btn.parent)
  if popo and popo.icon_ctrl then
    local btn2 = popo.icon_ctrl:search("icon/btn")
    btn2:click()
  end
end
local function checkCenterNeedCreate()
  for i = 1, 7 do
    local popo = m_popo_sets[i]
    if not popo then
      return
    end
    if popo.center_popo_delete ~= true then
      if not popo.showCenter and popo.icon_ctrl then
        popo.showCenter = true
        do
          local sub = ui.create_control(gx_center)
          sub:load_style("$gui/frame/popo/popo.xml", "center_icon")
          if popo.popo_def.icon == "default" then
            btn_pic.image = "$image\\popo\\tip.png|2,2,202,44"
          else
            btn_pic.image = "$image\\popo\\" .. popo.popo_def.icon .. ".png|2,2,202,44"
          end
          SetTip(sub, popo)
          sub:search("icon/btn"):insert_on_click(onClick)
          popo.centerCtrl = sub
          local cornerCtrl = popo.icon_ctrl
          local function checkFnc()
            local w_hide_anim = ui_qbar.ui_hide_anim.w_hide_anim
            local bs = cornerCtrl.size
            local ps = cornerCtrl.parent
            local ws = sub.size
            local pos = cornerCtrl:control_to_window(ui.point(0, 0)) + bs * 0.5
            local src = sub.offset + ws * 0.5
            local dis = pos - src
            local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 30
            if tick < 100 then
              tick = 100
            end
            w_hide_anim.svar.target = sub
            w_hide_anim:frame_clear()
            w_hide_anim.visible = true
            local f = w_hide_anim:frame_insert(100, sub)
            f.color1 = "FFFFFFFF"
            f.color2 = "CCFFFFFF"
            f:set_scale1(1, 1)
            f:set_scale2(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
            f = w_hide_anim:frame_insert(tick, sub)
            f.color1 = "CCFFFFFF"
            f.color2 = "99FFFFFF"
            f:set_scale1(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
            f:set_scale2(bs.x / ws.x, bs.y / ws.y)
            f:set_translate2(dis.x, dis.y)
            f = w_hide_anim:frame_insert(100, sub)
            f.color1 = "99FFFFFF"
            f.color2 = "00FFFFFF"
            f:set_scale1(bs.x / ws.x, bs.y / ws.y)
            f:set_scale2(bs.x / ws.x, bs.y / ws.y)
            f:set_translate1(dis.x, dis.y)
            f:set_translate2(dis.x, dis.y)
          end
          ui_qbar.ui_hide_anim.bind(sub, cornerCtrl, nil, checkFnc)
        end
      end
      if popo.showCenter and popo.centerCtrl then
        return
      end
    end
  end
end
local function deleteInvalidPopo()
  local ctrl = gx_center.control_head
  while ctrl do
    if not findPopo(ctrl) then
      ctrl.visible = false
      ctrl:post_release()
    end
    ctrl = ctrl.next
  end
end
local check_center_popo_livetime = function()
  local i = 1
  local cur_time = os.time()
  while i <= #m_popo_sets do
    local popo = m_popo_sets[i]
    if popo.center_popo_delete ~= true and os.difftime(cur_time, popo.start_time) > popo.popo_def.center_popo_showtime and sys.check(popo.centerCtrl) then
      popo.icon_ctrl.visible = true
      popo.centerCtrl.visible = false
      popo.center_popo_delete = true
    end
    i = i + 1
  end
end
function UpdateCenter()
  check_center_popo_livetime()
  deleteInvalidPopo()
  checkCenterNeedCreate()
end
function RunTest()
  AddPopo("test")
  AddPopo("test")
  AddPopo("test")
end
