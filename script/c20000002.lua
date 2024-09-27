--俯瞰苍界之鸦
local cm,m,o=GetID()
if not pcall(function() require("expansions/script/c20000000") end) then require("script/c20000000") end
fu_kurusu = fu_kurusu or {}
function fu_kurusu.A(c,code,cat,tg,op)
	aux.AddCodeList(c,20000001)
	local e1=fuef.B_A(c,0,cat,nil,"TG","O",fu_kurusu.A_con1,nil,tg,op,c)
	local e2=fuef.B_A(c,"TH","SH",nil,nil,"O",nil,fu_kurusu.A_cos2,fu_kurusu.A_tg2,fu_kurusu.A_op2,c)
	if not fu_kurusu.glo then
		fu_kurusu.glo={0,0}
		local ge1=fuef.FC(c,nil,EVENT_CHAINING,nil,nil,nil,fu_kurusu.glocon1,fu_kurusu.gloop1(1),1)
		local ge2=fuef.Clone(ge1,1,{"COD",EVENT_CHAIN_NEGATED},{"OP",fu_kurusu.gloop1()})
		local ge3=fuef.FC(c,nil,EVENT_PHASE_START+PHASE_DRAW,nil,nil,nil,nil,fu_kurusu.gloop3,1)
	end
	return e1,e2
end
function fu_kurusu.glocon1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsCode(20000001)
end
function fu_kurusu.gloop1(isadd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		fu_kurusu.glo[rp+1]=fu_kurusu.glo[rp+1]+(isadd and 1 or -1)
	end
end
function fu_kurusu.gloop3(e,tp,eg,ep,ev,re,r,rp)
	fu_kurusu.glo={0,0}
end
function fu_kurusu.RH(e,tp,eg,ep,ev,re,r,rp)
	local res={RESET_PHASE+PHASE_STANDBY,Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1}
	fuef.FC(e,{20000002,0},EVENT_PHASE+PHASE_STANDBY,nil,nil,1,nil,fu_kurusu.RH_op,tp,res,Duel.GetTurnCount())
end
function fu_kurusu.A_con1(e,tp,eg,ep,ev,re,r,rp)
	return fu_kurusu.glo[tp+1]>0
end
function fu_kurusu.A_cos2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return fugf.GetFilter(tp,"G","IsTyp+AbleTo",{"S","+R"},nil,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=fugf.SelectFilter(tp,"G","IsTyp+AbleTo",{"S","+R"},nil,1)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function fu_kurusu.A_tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return fugf.GetFilter(tp,"D","IsCode+AbleTo",{20000001,"H"},nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function fu_kurusu.A_op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=fugf.SelectFilter(tp,"D","IsCode+AbleTo",{20000001,"H"},nil,1):GetFirst()
	if not tc then return end
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end
function fu_kurusu.RH_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnCount()~=e:GetLabel() and fugf.GetFilter(tp,"G","IsTyp+AbleTo",{"S","H"},nil,1) then
		Duel.Hint(HINT_CARD,0,e:GetHandler():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=fugf.SelectFilter(tp,"G","IsTyp+AbleTo+GChk",{"S","H"},nil,1):GetFirst()
		if tc then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
	end
	e:Reset()
end
if not cm then return end
--------------------------------------------------------
function cm.initial_effect(c)
	local e1,e2=fu_kurusu.A(c,m,"TH",cm.tg,cm.op)
end
--e1
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return fucf.Filter(chkc,"IsLoc+IsTyp+AbleTo-IsCode","G","S","H",m) end
	if chk==0 then return fugf.GetFilter(tp,"G+G","IsTyp+AbleTo+TgChk-IsCode",{"S","H",e,m},nil,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=fugf.SelectTg(tp,"G+G","IsTyp+AbleTo+TgChk-IsCode",{"S","H",e,m},nil,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,16)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then fu_kurusu.RH(e,tp,eg,ep,ev,re,r,rp) end
end