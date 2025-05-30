--毒牙公主·梅杜莎
function c31280149.initial_effect(c)
	--融合素材
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,31280146,c31280149.ffilter,1,true,true)
	--破坏耐性
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c31280149.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--额外特召   
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280149,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,31280149)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCost(c31280149.cost)
	e3:SetTarget(c31280149.target)
	e3:SetOperation(c31280149.operation)
	c:RegisterEffect(e3)
	--怪兽装备
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280149,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31380149)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c31280149.condition1)
	e4:SetTarget(c31280149.target1)
	e4:SetOperation(c31280149.operation1)
	c:RegisterEffect(e4)
	--怪兽破坏 
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31280149,2))
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,31380149)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetCondition(c31280149.condition1)
    e5:SetCost(c31280149.cost2)
	e5:SetTarget(c31280149.target2)
	e5:SetOperation(c31280149.operation2)
	c:RegisterEffect(e5)            
end
c31280149.fusion_effect=true
function c31280149.ffilter(c)
	return c:IsRace(RACE_REPTILE)
end
function c31280149.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(31280146)
end
function c31280149.condition(e)
	return Duel.IsExistingMatchingCard(c31280149.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c31280149.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsCode(31280146)
end
function c31280149.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c31280149.costfilter,tp,LOCATION_ONFIELD,0,2,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c31280149.costfilter,tp,LOCATION_ONFIELD,0,2,2,nil,e,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function c31280149.spfilter(c,e,tp)
	return c:IsCode(31280146) and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280149.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280149.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31280149.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetFirstMatchingCard(c31280149.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg and Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(tg)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c31280149.immcon)
		e1:SetValue(c31280149.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tg:RegisterEffect(e1,true)
        if not tg:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e2,true)   
		end           
	end
end
function c31280149.immcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c31280149.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end
function c31280149.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c31280149.eqfilter(c,tp)
	return c:IsCode(31280146) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c31280149.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(c31280149.eqfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function c31280149.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,c31280149.eqfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc2=g:GetFirst()
		if Duel.Equip(tp,tc2,tc1,true) then
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c31280149.eqlimit)
			e1:SetLabelObject(tc1)
			tc2:RegisterEffect(e1)
		end
	end
end
function c31280149.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c31280149.costfilter1(c)
	return c:IsCode(31280146) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function c31280149.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c31280149.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()==100 then
			return Duel.IsExistingMatchingCard(c31280149.costfilter1,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		else return false end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c31280149.costfilter1,tp,LOCATION_GRAVE,0,1,2,nil)
	local cg=Duel.SendtoDeck(g,nil,nil,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,cg,cg,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function c31280149.defilter(c,e)
	return c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER)
end
function c31280149.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(c31280149.defilter,nil,e)
	if #rg>0 then
		Duel.Destroy(rg,REASON_EFFECT)
	end
end