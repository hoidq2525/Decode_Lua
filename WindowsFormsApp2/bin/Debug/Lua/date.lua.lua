text_id_flash = {
  [1028] = true
}
function ui_face_init()
  for i = 0, 95 do
    ui.reg_face(L("") .. i, L("$image/animation/face.xml|_") .. i)
  end
  for i = 1, 7 do
    ui.reg_face(L("00") .. i, L("$image/animation/monkey.xml|_00") .. i)
  end
  for i = 1, 9 do
    ui.reg_face(L("0") .. i, L("$image/animation/rabbit.xml|_0") .. i)
  end
  ui.reg_face(L("waitpk"), L("$image/animation/waitpk.xml|waitpk"))
end
ui_face_init()
COMPOSITE_INDEX = 1
CUSTOM_INDEX = 6
chat_expression_table = bo2.gv_expression
