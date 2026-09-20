--破式执行者·萨摩尔
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57310005)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFunRep(c,57310006,aux.FilterBoolFunction(Card.IsCode,57310005),2,127,true,true)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	aux.AddCodeList(c,57310005)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target1)
	e4:SetOperation(s.operation1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+id)
	e5:SetCost(s.eqcost)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.tgcon)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	--atk limit
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e7:SetCondition(s.tgcon)
	e7:SetValue(s.atlimit)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(s.negcon)
	e8:SetCost(s.negcost)
	e8:SetTarget(s.negtg)
	e8:SetOperation(s.negop)
	c:RegisterEffect(e8)
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.spfilter1(c,tp,sc)
	return c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(2) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and (c:IsControler(tp) or c:IsFaceup())
end
function s.spfilter2(c,tp,sc)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(10) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if  Duel.GetFlagEffect(tp,id)>0 then return false end
	return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_MZONE,0,1,nil,tp,c) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg1=g1:Select(tp,1,1,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	if sg1 then
		sg1:KeepAlive()
		e:SetLabelObject(sg1)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local sg=e:GetLabelObject()
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<2 then return false end
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.costfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(57310001)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local sg=Group.CreateGroup()
	for i=1,2 do
		local token=Duel.CreateToken(tp,57310005)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			sg:AddCard(token)
		end
	end
	if #sg>0 then
		Duel.SpecialSummonComplete()
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_REMOVED,0,1,nil,tp) end
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE+LOCATION_REMOVED,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE+LOCATION_REMOVED,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if not Duel.Equip(tp,tc,c) then return end
		e:SetLabelObject(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.tgcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg:GetCount()>0
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.lpfilter(c,tp)
	return c:GetFlagEffect(id)~=0 and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:IsAbleToGraveAsCost()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if chk==0 then return eqg:IsExists(s.lpfilter,1,nil,tp) end
	local ec=eqg:FilterSelect(tp,s.lpfilter,1,1,nil,tp)
	Duel.SendtoGrave(ec,REASON_COST)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
