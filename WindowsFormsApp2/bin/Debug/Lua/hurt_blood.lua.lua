local sig = "ui_dead.hurt_blood"
function on_liveup(obj, ty)
  if ty == bo2.eFlagType_ObjMemory then
    local value = obj:get_flag_objmem(bo2.eFlagObjMemory_DeadType)
    if value ~= 0 then
      return
    end
  end
  if sys.check(w_hurtblood) then
    w_hurtblood.visible = false
  end
  obj:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_DeadType, sig)
end
function on_show(obj, ty)
  if not sys.check(w_hurtblood) then
    local ctr = ui.create_control(ui_main.w_top)
    ctr:load_style("$gui/frame/dead/hurt_blood.xml", "hurt_blood")
  end
  w_hurtblood.visible = true
  local crt = w_hurtblood:search("pic_blood")
  crt:reset()
  obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_DeadType, on_liveup, sig)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_show_hurtblood, on_show, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, on_liveup, sig)
