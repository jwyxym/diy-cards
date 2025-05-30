--梅杜希亚娜
function c31280148.initial_effect(c)
	--融合素材
	c:EnableReviveLimit()
	aux.AddFusionProcCodeRep(c,31280146,2,false,false)
	--改变卡名   
    aux.EnableChangeCode(c,31280146,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_SZONE,c31280148.condition)
	--战破抗性
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c31280148.condition1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--效果免疫    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31280148.condition2)
	e2:SetValue(c31280148.efilter)
	c:RegisterEffect(e2)
	--降防并送去墓地
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280148,0))
	e3:SetCategory(CATEGORY_DEFCHANGE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c31280148.condition3)
	e3:SetTarget(c31280148.target)
	e3:SetOperation(c31280148.operation)
	c:RegisterEffect(e3)
	--墓地特召    
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(31280148,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,31280148)
	e4:SetCondition(c31280148.condition4)
	e4:SetTarget(c31280148.target4)
	e4:SetOperation(c31280148.operation4)
	c:RegisterEffect(e4)
end
function c31280148.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetEquipTarget() or c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
end
function c31280148.indfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_REPTILE) and c:IsFaceup() and not c:IsOriginalCodeRule(31280148)
end
function c31280148.condition1(e)
	return Duel.IsExistingMatchingCard(c31280148.indfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280148.condition2(e)
	return Duel.IsExistingMatchingCard(c31280148.indfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsBattlePhase()
end
function c31280148.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c31280148.condition3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle()
end
function c31280148.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsDefenseAbove(400) 
    	and c:IsStatus(STATUS_OPPO_BATTLE) and bc~=nil end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,bc,1,0,0)
end
function c31280148.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local bc=e:GetHandler():GetBattleTarget()
	if c:IsFacedown() or not c:IsRelateToEffect(e) 
    	or c:GetDefense()<400 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-400)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) 
    	and bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
		Duel.SendtoGrave(bc,REASON_EFFECT)
	end
end
function c31280148.spfilter(c)
	return aux.IsCodeOrListed(c,31280146) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c31280148.condition4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280148.spfilter,tp,LOCATION_MZONE,0,1,nil) and aux.exccon(e)
end
function c31280148.target4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280148.operation4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
    	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)		
	end
end