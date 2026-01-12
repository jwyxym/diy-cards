--银冰龙少女·菲琳
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280116)
	--同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1,1)
	c:EnableReviveLimit()
	--加入手卡    
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--适用效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
	--同调召唤
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)    
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,tp,cid)
	return not re:GetHandler():IsCode(31280116)
end
function s.thfilter(c,check)
	return aux.IsCodeOrListed(c,31280116) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or check)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local check=c:IsSummonLocation(LOCATION_EXTRA)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,check) end
    if check then
    	e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    else
    	e:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)        
    end    
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local check=c:IsSummonLocation(LOCATION_EXTRA)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,check)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.desfilter(c)
	return c:GetAttack()<c:GetTextAttack() and c:IsFaceup()
end
function s.lvfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1)
end    
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
    local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return (b1 or b2) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 end
    local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
    local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,3),1},
		{b2,aux.Stringid(id,4),2})
    if op==1 then
    	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    	if sg:GetCount()>0 then	
    		Duel.Destroy(sg,REASON_EFFECT)
    	end    
    elseif op==2 then
    	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()>0 then
        	Duel.ConfirmCards(tp,hg)
        	local mg=hg:Filter(s.lvfilter,nil)
            for tc in aux.Next(mg) do 
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
            end
            Duel.ShuffleHand(1-tp)
        end
    end   
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
function s.syncfilter(c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsSynchroSummonable(nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end