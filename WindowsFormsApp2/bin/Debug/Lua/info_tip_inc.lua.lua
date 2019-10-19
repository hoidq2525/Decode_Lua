no_info = 1
guild_account_info = 2
schedule_info = 3
account_info = 4
prison_info = 5
tmpbattle_info = 6
info_menu = {
  {
    text = ui.get_text(L("info_tip|no_quest")),
    id = 1
  },
  {
    text = ui.get_text(L("info_tip|quest_account")),
    id = 2,
    callback = ui_info_tip.callback_account,
    quest_id = 5001
  },
  {
    text = ui.get_text(L("info_tip|quest_sch_cd")),
    id = 3,
    callback = ui_info_tip.callback_sch
  },
  {
    text = ui.get_text(L("info_tip|quest_account")),
    id = 4,
    callback = ui_info_tip.callback_account,
    quest_id = 5011
  },
  {
    text = ui.get_text(L("info_tip|quest_prison")),
    id = 5,
    callback = ui_info_tip.callback_prison
  },
  {
    text = ui.get_text(L("info_tip|tmpbattle")),
    id = 6,
    callback = ui_info_tip.callback_tmpbattle
  }
}
