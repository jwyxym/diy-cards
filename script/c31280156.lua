--梅杜莎
function c31280156.initial_effect(c)
	aux.AddCodeList(c,31280146)
	--降攻特召
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280156,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280156)
	e1:SetCondition(c31280156.condition)
	e1:SetTarget(c31280156.target)
	e1:SetOperation(c31280156.operation)
	c:RegisterEffect(e1)
	--卡组检索 
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280156,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,31380148)
	e2:SetTarget(c31280156.target1)
	e2:SetOperation(c31280156.operation1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--怪兽装备
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280156,2))
	e4:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_RELEASE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31380156)
	e4:SetTarget(c31280156.target2)
	e4:SetOperation(c31280156.operation2)
	c:RegisterEffect(e4)
end    
function c31280156.cfilter(c)
	return c:IsCode(31280146) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280156.cfilter1(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280156.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c31280156.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		or Duel.IsExistingMatchingCard(c31280156.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c31280156.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280156.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function c31280156.thfilter(c)
	return (c:IsCode(31280146) or aux.IsCodeListed(c,31280146) and c:IsType(TYPE_MONSTER) and not c:IsCode(31280156))
		and c:IsAbleToHand()
end
function c31280156.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280156.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280156.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280156.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c31280156.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(31280146) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c31280156.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280156.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c31280156.eqspfilter(c)
	return c:IsFaceup() and c:IsCode(31280146)
end
function c31280156.rfilter(c,tp)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsRace(RACE_REPTILE) and c:GetEquipGroup():IsExists(c31280156.eqspfilter,1,nil) 
    	and c:IsReleasableByEffect() and c:IsControler(tp)
end
function c31280156.spfilter(c,e,tp)
	return aux.IsMaterialListCode(c,31280146) and c:IsLevelBelow(8) and c:IsType(TYPE_FUSION) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280156.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280156.eqfilter),tp,LOCATION_DECK,0,1,1,nil,c,tp)
		local sc=g:GetFirst()
		if sc and Duel.Equip(tp,sc,c) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(c31280156.eqlimit)
			sc:RegisterEffect(e1)
            if Duel.IsExistingMatchingCard(c31280156.rfilter,tp,LOCATION_MZONE,0,1,nil,tp)
				and Duel.IsExistingMatchingCard(c31280156.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(31280156,3)) then
				Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE) 
                local rg=Duel.SelectMatchingCard(tp,c31280156.rfilter,tp,LOCATION_MZONE,0,1,1,nil)
				if #rg>0 and Duel.Release(rg,REASON_EFFECT)~=0 then  
                	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local sg=Duel.SelectMatchingCard(tp,c31280156.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
					local tc=sg:GetFirst()
					if tc and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then
						tc:SetMaterial(nil)
						Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        				tc:CompleteProcedure() 
					end                        
				end                        
			end                           
		end
	end
end
function c31280156.eqlimit(e,c)
	return c==e:GetLabelObject()
end