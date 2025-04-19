--拉芙希妮·深池，“领袖”
function c31280311.initial_effect(c)
	c:EnableReviveLimit()
	--特召限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c31280311.splimit)
	c:RegisterEffect(e1)
    --公开检索
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,31280311)
	e2:SetOperation(c31280311.operation)
	c:RegisterEffect(e2)
	--魔陷盖放    
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,31380311)
	e3:SetCondition(c31280311.condition1)
	e3:SetTarget(c31280311.target1)
	e3:SetOperation(c31280311.operation1)
	c:RegisterEffect(e3)
	--墓地回手
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,31380312)
	e4:SetCondition(c31280311.condition2)
	e4:SetTarget(c31280311.target2)
	e4:SetOperation(c31280311.operation2)
	c:RegisterEffect(e4)
end
function c31280311.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xca3)
end
function c31280311.thfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function c31280311.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local fid=c:GetFieldID()
	c:RegisterFlagEffect(9822220,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,66)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
    local g=Duel.GetMatchingGroup(c31280311.thfilter,tp,LOCATION_DECK,0,nil)
    	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31280311,0)) then
        	Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
            local mg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
			if g and #mg>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local tg=mg:Select(tp,1,1,nil)
				Duel.SendtoGrave(tg,REASON_EFFECT)
            end
        end
end
function c31280311.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsSetCard(0xca3)
end
function c31280311.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280311.spfilter,1,nil,tp)
end
function c31280311.filter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c31280311.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsPublic()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280311.filter,tp,LOCATION_DECK,0,1,nil) 
    and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function c31280311.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c31280311.filter,tp,LOCATION_DECK,0,1,1,nil)
    local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsPublic()
    if g:GetCount()<=0 then return end 
    local tc=g:GetFirst()
    local b=check and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
    if (not b or Duel.SelectOption(tp,1191,1152)==0) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	else
		Duel.SpecialSummon(c,0,tp,tp,false,aux.DrytronSpSummonType(c),POS_FACEUP)
        
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    Duel.SSet(tp,tc)   
end
function c31280311.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsPublic()
end
function c31280311.condition2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp and not Duel.IsExistingMatchingCard(c31280311.cfilter,tp,LOCATION_HAND,0,1,nil)
end
function c31280311.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c31280311.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end