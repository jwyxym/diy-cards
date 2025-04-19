--深池逐火战士
function c31280306.initial_effect(c)
	aux.AddCodeList(c,31280320)
	c:EnableReviveLimit()
	--卡组堆墓加攻    
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31280306)
	e1:SetCondition(c31280306.condition)
	e1:SetTarget(c31280306.target)
	e1:SetOperation(c31280306.operation)
	c:RegisterEffect(e1)
	--素材检测    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c31280306.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--离场生token    
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,31380306)
	e3:SetCondition(c31280306.condition1)
	e3:SetTarget(c31280306.target1)
	e3:SetOperation(c31280306.operation1)
	c:RegisterEffect(e3)
	--墓地特召
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,31380307)
    e4:SetCondition(c31280306.condition2)
	e4:SetTarget(c31280306.target2)
	e4:SetOperation(c31280306.operation2)
	c:RegisterEffect(e4) 
end
function c31280306.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end    
function c31280306.tgfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and not c:IsCode(31280306) and c:IsAbleToGrave()
end
function c31280306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280306.tgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280306.tgfilter,tp,LOCATION_DECK,0,2,nil) 
    	and g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function c31280306.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280306.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		if tg:GetCount()>0 and Duel.SendtoGrave(tg,nil,REASON_EFFECT)~=0 then
			local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
            if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
            	Duel.BreakEffect()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(ct*400)
				c:RegisterEffect(e1)
			end
		end
	end
end    
function c31280306.valfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function c31280306.valcheck(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if g:IsExists(c31280306.valfilter,2,nil,tp) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c31280306.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c31280306.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380306,TYPES_TOKEN_MONSTER,400,400,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c31280306.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380306,TYPES_TOKEN_MONSTER,400,400,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,31380306)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(e2)
        local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(e3)
		Duel.SpecialSummonComplete()
	end
end
function c31280306.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL)
end
function c31280306.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c31280306.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280306.sctfil(c) 
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER)
end 
function c31280306.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(c31280306.sctfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then   
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and mg:CheckWithSumGreater(Card.GetLevel,c:GetLevel(),c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c31280306.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(c31280306.sctfil,tp,LOCATION_MZONE,0,nil) 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local lv=c:GetOriginalLevel()
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,"Greater")
	local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,c,lv,"Greater")
	aux.GCheckAdditional=nil
		c:SetMaterial(mat)
		Duel.Release(mat,REASON_EFFECT)
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end