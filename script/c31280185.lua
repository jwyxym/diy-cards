--淬铁龙匠 燎火的扳手铁匠
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--回手或特召    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,31280187)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.confilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_PENDULUM) or c:IsSetCard(0xcca1))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)		
		e1:SetValue(400)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
    	local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
    Duel.SpecialSummonComplete()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetBaseAttack() or c:GetDefense()>c:GetBaseDefense()
end
function s.desfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 
end    
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
    	Duel.Destroy(tc,REASON_EFFECT)
	end        
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.thfilter(c,e,tp)
	local b1=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
    local b2=c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	return (c:IsSetCard(0xcca1) or c:IsType(TYPE_PENDULUM)) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (c:IsAbleToHand() 
        	or ((b1 or b2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
    	local b1=tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
    	local b2=tc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or not (b1 or b2) or Duel.SelectOption(tp,1190,1152)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end