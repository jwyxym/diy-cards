--展羽行猎之鸦
local cm,m,o=GetID()
if not pcall(function() require("expansions/script/c20000002") end) then require("script/c20000002") end
function cm.initial_effect(c)
	local e1,e2=fu_kurusu.A(c,m,"DES",cm.tg,cm.op)
end
--e1
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return fugf.GetFilter(tp,"MS+MS","TgChk",e,e:GetHandler(),1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=fugf.SelectTg(tp,"MS+MS","TgChk",e,e:GetHandler(),1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then fu_kurusu.RH(e,tp,eg,ep,ev,re,r,rp) end
end