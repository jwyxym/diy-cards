--深池造物 守墓石像
function c31280305.initial_effect(c)
	aux.AddCodeList(c,31280304)
	c:EnableReviveLimit()
	--效破抗性
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(c31280305.condition)
	e1:SetValue(c31280305.value)
	c:RegisterEffect(e1)
	--除外生token送墓    
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,31280305)
	e2:SetCondition(c31280305.condition1)
    e2:SetTarget(c31280305.target1)
	e2:SetOperation(c31280305.operation1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
    --回场送墓
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_REMOVED)
    e4:SetCondition(c31280305.condition2)
	e4:SetTarget(c31280305.target2)
	e4:SetOperation(c31280305.operation2)
	c:RegisterEffect(e4)
end
function c31280305.condition(e)
	return e:GetHandler():IsDefensePos()
end
function c31280305.value(e,re,rp)
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function c31280305.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function c31280305.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380305,0,TYPES_TOKEN_MONSTER,0,3100,6,RACE_ROCK,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c31280305.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,31380305,0,TYPES_TOKEN_MONSTER,0,3100,6,RACE_ROCK,ATTRIBUTE_EARTH) then return end
    local token=Duel.CreateToken(tp,31380305)
    local ec=aux.ExceptThisCard(e)
    if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0
    	and	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ec)
		and Duel.SelectYesNo(tp,aux.Stringid(31280305,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,ec)
		Duel.BreakEffect()
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
function c31280305.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c31280305.sctfil(c) 
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER)
end 
function c31280305.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(c31280305.sctfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then   
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and mg:CheckWithSumGreater(Card.GetLevel,c:GetLevel(),c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c31280305.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(c31280305.sctfil,tp,LOCATION_MZONE,0,nil) 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local lv=c:GetOriginalLevel()
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,"Greater")
	local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,c,lv,"Greater")
	aux.GCheckAdditional=nil
		c:SetMaterial(mat)
        if Duel.Release(mat,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) 
        	and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 
            and Duel.SelectYesNo(tp,aux.Stringid(31280305,0)) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,ec)
			Duel.BreakEffect()
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_EFFECT)
        end       
end