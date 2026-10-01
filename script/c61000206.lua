--篡夺分与之王神剑
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61000203)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_F)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.spcon)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.eftg2)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.filter(c)
	return c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		e:SetLabel(tg:GetCount())
	else
		e:SetLabel(0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and e:GetLabel()~=0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetLabel(),nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetLabel(),e:GetLabel(),nil)
		if g:GetCount()>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsCode(61000203) and c:GetEquipGroup():IsContains(e:GetHandler())
end
function s.eftg2(e,c)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(61000203) and c:GetEquipGroup():IsContains(e:GetHandler())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(61000203) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.spfilter2(c,e,tp)
	return c:IsPublic() and c:IsCode(61000203) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) and
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=false
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) then
		if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 or Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) then
			for lv=1,12 do
				if Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPE_MONSTER,-2,-2,lv,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP) then
					b2=true
					break
				end
			end
		end
		b2=b2 or Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
	end
	if chk==0 then return b1 or b2 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	local ss=false
	for p in aux.TurnPlayers() do
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),p,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,p)
			and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.spfilter),p,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,p):GetFirst()
			if Duel.SpecialSummonStep(sc,SUMMON_TYPE_RITUAL,p,p,false,true,POS_FACEUP) then
				ss=true
				sc:CompleteProcedure()
			end
		end
	end
	if ss then
		Duel.SpecialSummonComplete()
	end
end