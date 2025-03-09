--狂剑·炎雪
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(this.spcon)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(this.tg)
	e2:SetOperation(this.op)
	c:RegisterEffect(e2)
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function this.thfilter(c)
	return c:IsSetCard(0x97c0) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function this.spfilter(c)
    return c:IsAbleToRemove() and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_GRAVE,0,1,nil)
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
        Duel.BreakEffect()
        if Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc2=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if tc2 then
				Duel.SendtoHand(tc2,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc2)
			end
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(this.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
    end
end
function this.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function this.filter(c)
	return c:IsSetCard(0x97c0) and c:IsFaceup() and c:IsAbleToHand()
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end