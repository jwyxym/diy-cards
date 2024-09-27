--咒鸦的契念歌
local cm,m,o=GetID()
if not pcall(function() require("expansions/script/c20000002") end) then require("script/c20000002") end
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	local e1=fuef.A(c)
	local e2=fuef.I(c,nil,"SH",nil,"S",1,nil,cm.cos2,cm.tg2,cm.op2,c)
end
--e2
function cm.cos2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return fugf.GetFilter(tp,"G","IsTyp+AbleTo",{"S","+R"},nil,1) and Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=fugf.SelectFilter(tp,"G","IsTyp+AbleTo",{"S","+R"},nil,1)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return fugf.GetFilter(tp,"D","IsCodeListed+IsTyp+AbleTo",{20000001,"QU","H"},nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=fugf.SelectFilter(tp,"D","IsCodeListed+IsTyp+AbleTo",{20000001,"QU","H"},nil,1):GetFirst()
	if not tc then return end
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	if fu_kurusu.glo[tp+1]>0 and fugf.GetFilter(tp,"D","IsCode+AbleTo",{e:GetLabel(),"H"},nil,1) 
		and Duel.SelectYesNo(tp,1190) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		tc=fugf.SelectFilter(tp,"D","IsCode+AbleTo",{e:GetLabel(),"H"},nil,1):GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end