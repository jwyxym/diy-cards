--路观大王
local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.lkfiliter,3,4,nil)
	c:EnableReviveLimit()
	aux.EnableChangeCode(c,41990020,LOCATION_MZONE+LOCATION_GRAVE)
	c:EnableCounterPermit(0x4199)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,7))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tg)
	e2:SetOperation(s.e2op)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetCondition(s.atkcon)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,4))
	e3b:SetCategory(CATEGORY_DAMAGE)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCondition(s.damcon)
	e3b:SetOperation(s.damop)
	c:RegisterEffect(e3b)
	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(id,5))
	e3c:SetCategory(CATEGORY_CONTROL)
	e3c:SetType(EFFECT_TYPE_QUICK_O)
	e3c:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetCountLimit(1)
	e3c:SetCode(EVENT_FREE_CHAIN)
	e3c:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3c:SetCondition(s.ctcon)
	e3c:SetCost(s.ctcost)
	e3c:SetTarget(s.cttg)
	e3c:SetOperation(s.ctop)
	c:RegisterEffect(e3c)
	local e3d=Effect.CreateEffect(c)
	e3d:SetDescription(aux.Stringid(id,6))
	e3d:SetType(EFFECT_TYPE_QUICK_O)
	e3d:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3d:SetRange(LOCATION_MZONE)
	e3d:SetCountLimit(1)
	e3d:SetCode(EVENT_FREE_CHAIN)
	e3d:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3d:SetCondition(s.tgcon)
	e3d:SetCost(s.tgcost)
	e3d:SetTarget(s.tgtg)
	e3d:SetOperation(s.tgop)
	c:RegisterEffect(e3d)
end


function s.lkfiliter(c)
	return c:IsLinkRace(RACE_ILLUSION) or c:IsLinkRace(RACE_ZOMBIE) or c:IsLinkRace(RACE_FIEND)
end


function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(id)~=Duel.GetTurnCount()-1
end
function s.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.e2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x4199,1)
	local c=e:GetHandler()
	local ops={}
	local opval={}
	if e:GetHandler():GetFlagEffectLabel(id)~=Duel.GetTurnCount()-1 
	and Duel.IsExistingMatchingCard(Card.IsSpecialSummonableCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		table.insert(ops,aux.Stringid(id,0))
		table.insert(opval,0)
	end
	if e:GetHandler():GetFlagEffectLabel(id)~=Duel.GetTurnCount()-1
	and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0) then
		table.insert(ops,aux.Stringid(id,1))
		table.insert(opval,1)
	end
	if #ops==0 then return end
	local sel=Duel.SelectOption(tp,table.unpack(ops))
	local op=opval[sel+1]
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
	if op==1 then
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if ft1+ft2<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ct=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		ct=ct+1
		if ct>ft1+ft2 then ct=ft1+ft2 end
		local sum=0
		for i=1,ct do
			local token=Duel.CreateToken(tp,41990023)
			local pos=0
			if ft2>0 and (ft1<=0 or Duel.SelectYesNo(tp,aux.Stringid(id,4))) then
				pos=1-tp
				ft2=ft2-1
			else
				pos=tp
				ft1=ft1-1
			end
			if Duel.SpecialSummonStep(token,0,tp,pos,false,false,POS_FACEUP) then
				token:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
				if pos==tp then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
				token:RegisterEffect(e2)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				token:RegisterEffect(e3)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_CANNOT_BE_RITUAL_MATERIAL)
				token:RegisterEffect(e4)
				sum=sum+1 
				end
			end
		end
		Duel.SpecialSummonComplete()
		c:AddCounter(0x4199,sum)
	end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount())
end


function s.atkcon(e)
	return e:GetHandler():GetCounter(0x4199)>=1
end
function s.atktg(e,c)
	local hc=e:GetHandler()
	return c==hc or (c:IsControler(hc:GetControler()) and c:GetFlagEffect(id+1)~=0)
end


function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x4199)<2 then return false end
	local a=Duel.GetAttacker()
	return a==c or (a:IsControler(tp) and a:GetFlagEffect(id+1)~=0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end


function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x4199)>=3
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4199,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4199,3,REASON_COST)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end


function s.tkfilter(c)
	return c:IsCode(41990023) and c:IsReleasable()
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x4199)>=4 and Duel.CheckReleaseGroup(tp,s.tkfilter,2,nil)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,0x4199,3,REASON_COST)
		and Duel.CheckReleaseGroup(tp,s.tkfilter,2,nil)
	end
	c:RemoveCounter(tp,0x4199,3,REASON_COST)
	local g=Duel.SelectReleaseGroup(tp,s.tkfilter,2,2,nil)
	Duel.Release(g,REASON_COST)
end
function s.tgfilter(c)
	return c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #tc>0 then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end