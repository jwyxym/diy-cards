--小甜心★梅杜莎
function c31280155.initial_effect(c)
	--融合素材
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,31280146,{31280149,c31280155.matfilter},true,true)
	--怪兽装备
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280155,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,31280155)
    e1:SetCondition(c31280155.condition)
    e1:SetCost(c31280155.cost)
	e1:SetTarget(c31280155.target)
	e1:SetOperation(c31280155.operation)
	c:RegisterEffect(e1)
	--魔陷盖放 
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280155,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31380155)
	e2:SetTarget(c31280155.target1)
	e2:SetOperation(c31280155.operation1)
	c:RegisterEffect(e2)
	--效果无效     
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280155,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c31280155.condition2)
	e3:SetOperation(c31280155.operation2)
	c:RegisterEffect(e3)
end
function c31280155.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(6)
end
function c31280155.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
function c31280155.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHandAsCost()
end
function c31280155.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280155.costfilter,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280155.costfilter,tp,LOCATION_ONFIELD,0,1,2,c)
	Duel.HintSelection(g)
	Duel.SendtoHand(g,nil,REASON_COST)
    e:SetLabel(g:GetCount())
end
function c31280155.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(31280146) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c31280155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local ct=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280155.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,c,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,ct+1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c31280155.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local ct=e:GetLabel()
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<ct then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280155.eqfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,ct+1,nil,c,tp)
		local sc=g:GetFirst()
		while sc do
        	Duel.Equip(tp,sc,c,true,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(c31280155.eqlimit)
			sc:RegisterEffect(e1)
            sc=g:GetNext()
		end
        Duel.EquipComplete()
	end
end
function c31280155.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c31280155.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or not c:IsOnField())
end
function c31280155.ssfilter(c,tp)
	return aux.IsCodeListed(c,31280146) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		and not Duel.IsExistingMatchingCard(c31280155.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function c31280155.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280155.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c31280155.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,c31280155.ssfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then Duel.SSet(tp,tc) end
end
function c31280155.disfilter(c)
	return c:IsFaceup() and c:IsCode(31280146) and c:GetOriginalType()&TYPE_MONSTER>0 
end
function c31280155.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsExistingMatchingCard(c31280155.disfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetFlagEffect(tp,31280155)==0
end
function c31280155.operation2(e,tp,eg,ep,ev,re,r,rp)	
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(31280155,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,c31280155.disfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT) then
			Duel.Hint(HINT_CARD,0,31280155)
            local rc=re:GetHandler()
			if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and tc:IsOriginalCodeRule(31280148) and Duel.SelectYesNo(tp,aux.Stringid(31280155,5)) then
            	Duel.BreakEffect()
        		Duel.Destroy(rc,REASON_EFFECT)
            end                	
		end
        Duel.RegisterFlagEffect(tp,31280155,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end