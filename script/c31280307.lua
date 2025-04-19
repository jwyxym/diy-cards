--深池逐火护卫
function c31280307.initial_effect(c)
	aux.AddCodeList(c,31280320)
	c:EnableReviveLimit()
	--复制伤害
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,31280307)
    e1:SetCondition(c31280307.condition)
	e1:SetTarget(c31280307.target)
	e1:SetOperation(c31280307.operation)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c31280307.condition1)
	e2:SetOperation(c31280307.target1)
	c:RegisterEffect(e2)
    --素材检测    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c31280307.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
    --离场生token    
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,31380307)
	e4:SetCondition(c31280307.condition2)
	e4:SetTarget(c31280307.target2)
	e4:SetOperation(c31280307.operation2)
	c:RegisterEffect(e4)
    --墓地特召
    local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,31380308)
    e5:SetCondition(c31280307.condition3)
	e5:SetTarget(c31280307.target3)
	e5:SetOperation(c31280307.operation3)
	c:RegisterEffect(e5) 
end
function c31280307.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function c31280307.filter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_DRAGON)
end
function c31280307.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c31280307.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280307.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c31280307.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c31280307.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) 
    	and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK) then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
        if e:GetHandler():GetFlagEffect(31280307)>0 then
        	Duel.BreakEffect()
			Duel.Damage(1-tp,1600,REASON_EFFECT)
        end    	
	end
end
function c31280307.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
function c31280307.target1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(31280307,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31280307,0))
end
function c31280307.valfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function c31280307.valcheck(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if g:IsExists(c31280307.valfilter,2,nil,tp) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c31280307.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c31280307.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380307,TYPES_TOKEN_MONSTER,800,800,6,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c31280307.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380307,TYPES_TOKEN_MONSTER,800,800,6,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,31380307)
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
function c31280307.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL)
end
function c31280307.condition3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c31280307.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280307.sctfil(c) 
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER)
end 
function c31280307.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(c31280307.sctfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then   
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and mg:CheckWithSumGreater(Card.GetLevel,c:GetLevel(),c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c31280307.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(c31280307.sctfil,tp,LOCATION_MZONE,0,nil) 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local lv=c:GetOriginalLevel()
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,"Greater")
	local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,c,lv,"Greater")
	aux.GCheckAdditional=nil
		c:SetMaterial(mat)
		Duel.Release(mat,REASON_EFFECT)
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end