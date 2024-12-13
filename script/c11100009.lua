--铁机龙战·爆裂铠甲
local m=11100009
local cm=_G["c"..m]
function c11100009.initial_effect(c)
	 local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(cm.con1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_TO_GRAVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY) 
	e2:SetCountLimit(1,m)
	e2:SetCondition(function(e) 
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
	e2:SetTarget(cm.ttg) 
	e2:SetOperation(cm.top) 
	c:RegisterEffect(e2)	 
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(cm.con4)
	e4:SetTarget(cm.desreptg)
	e4:SetValue(cm.desrepval)
	e4:SetOperation(cm.regop)
	c:RegisterEffect(e4)
end
function cm.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil)
	end
end
function cm.top(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		local lg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
		local zone=0
		for tc in aux.Next(lg) do
		local seq=tc:GetSequence()
		if seq>0 then zone=zone|(1<<(seq-1)) end
		if seq<4 then zone=zone|(1<<(seq+1)) end
		end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	else
	Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function cm.splimit2(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_PSYCHO)
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
function cm.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and not c:IsReason(REASON_REPLACE) end
function cm.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(cm.filter,1,nil,tp)
		and c:IsDestructable() end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function cm.desrepval(e,c)
	return cm.repfilter(c,e:GetHandlerPlayer())
end
function cm.filter3(c)
return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLinkAbove(3)
end
function cm.filter2(c)
return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsType(TYPE_LINK)
end
function cm.filter(c)
return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER)
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
local tc=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
Duel.Equip(tp,c,tc)
local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(cm.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(tc)
		c:RegisterEffect(e2)
 local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)
end
function cm.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function cm.con4(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
return rp==c:GetControler() and e:GetHandler():GetEquipTarget() end









