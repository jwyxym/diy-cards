--鸦之魔女
local cm,m,o=GetID()
if not pcall(function() require("expansions/script/c20000000") end) then require("script/c20000000") end
function cm.initial_effect(c)
	local e1=fuef.QO(c,0,nil,nil,"TG","H",nil,cm.con1,cm.cos1,cm.tg1,cm.op1,c)
	local e2=fuef.FTO(c,"SP","SP",EVENT_PHASE+PHASE_BATTLE_START,nil,"H",1,nil,nil,cm.tg2,cm.op2,c)
end
--e1
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return #fugf.Get(tp,"M")==0
end
function cm.cosf1(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(true,true,false)
	if not (c:IsType(TYPE_SPELL) and c:IsDiscardable() and te and te:IsHasProperty(16) and te:GetOperation()) then return false end
	return te:GetTarget() and te:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)
end
function cm.cos1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	if chkc then return te and te:GetTarget() and te:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return e:GetLabel()~=Duel.GetFlagEffectLabel(tp,m) and fugf.GetFilter(tp,"H",cm.cosf1,{e,tp,eg,ep,ev,re,r,rp},nil,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=fugf.SelectFilter(tp,"H",cm.cosf1,{e,tp,eg,ep,ev,re,r,rp},nil,1):GetFirst()
	te=tc:CheckActivateEffect(true,true,false)
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	fuef.Set(e,{"PRO",te:GetProperty()},{"LAB",te:GetLabel()},{"LABOBJ",te:GetLabelObject()})
	tc=te:GetTarget()
	if tc then tc(e,tp,eg,ep,ev,re,r,rp,1) end
	fuef.Set(te,{"LAB",e:GetLabel()},{"LABOBJ",e:GetLabelObject()})
	fuef.Set(e,"LABOBJ",te)
	Duel.ClearOperationInfo(0)
	Duel.RegisterFlagEffect(tp,m,RESET_CHAIN,0,1,100)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	fuef.Set(e,{"LAB",te:GetLabel()},{"LABOBJ",te:GetLabelObject()})
	if te:GetOperation() then te:GetOperation()(e,tp,eg,ep,ev,re,r,rp) end
	fuef.Set(te,{"LAB",e:GetLabel()},{"LABOBJ",e:GetLabelObject()})
end
--e2
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SpecialSummonStep(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	local fid=e:GetHandler():GetFieldID()
	e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	fuef.FC(e,1,EVENT_PHASE+PHASE_BATTLE,EFFECT_FLAG_IGNORE_IMMUNE,nil,1,cm.op2con,cm.op2op,tp,nil,fid,e:GetHandler())
	Duel.SpecialSummonComplete()
end
function cm.op2con(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(m)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function cm.op2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end