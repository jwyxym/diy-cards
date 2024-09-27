--驰行巡域之鸦
local cm,m,o=GetID()
if not pcall(function() require("expansions/script/c20000002") end) then require("script/c20000002") end
function cm.initial_effect(c)
	local e1,e2=fu_kurusu.A(c,m,"TD",cm.tg,cm.op)
end
--e1
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return fucf.Filter(chkc,"IsLoc+AbleTo","G","D") end
	if chk==0 then return fugf.GetFilter(tp,"G+G","TgChk+AbleTo",{e,"D"},nil,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=fugf.SelectTg(tp,"G+G","TgChk+AbleTo",{e,"D"},nil,1,5)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g<1 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	fu_kurusu.RH(e,tp,eg,ep,ev,re,r,rp)
end