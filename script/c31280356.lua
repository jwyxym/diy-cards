--新约·黑之章
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280357)
    aux.EnablePendulumAttribute(c,false)
	--超量召唤
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	c:EnableReviveLimit()
	--怪兽效破耐性    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--伤害
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
  	--效破耐性    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--回手或特召    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.tspcon1)
	e4:SetTarget(s.tsptg)
	e4:SetOperation(s.tspop)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
	e5:SetCode(EVENT_DESTROYED)
    e5:SetCondition(s.tspcon2)
	c:RegisterEffect(e5)
	--放置 
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCountLimit(1,id+o*10000)
    e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)   
end
function s.mfilter(c,xyzc)
	return c:IsSetCard(0x3ca1)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetLevel)==1
end
function s.efilter(e,re,rp)
	return not re:GetHandler():IsSetCard(0x3ca1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tp,e:GetHandler(),0,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT) and c:IsRelateToEffect(e) then
    	Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end
function s.tspcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tspcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_PZONE)
end
function s.tspfilter(c,e,tp,check)
	return c:IsSetCard(0x3ca1) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    local ct=c:GetPreviousOverlayCountOnField()
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tspfilter(chkc) end
	if chk==0 then return ((ct>0 and c:IsPreviousLocation(LOCATION_MZONE)) or c:IsPreviousLocation(LOCATION_PZONE)) 
    	and Duel.IsExistingTarget(s.tspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
end
function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if tc:IsRelateToEffect(e) then
		if tc:IsAbleToHand() and (not (check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.SelectOption(tp,1190,1152)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)			
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
    end     
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(31280357)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,1,nil)
    	and 1-tp==Duel.GetTurnPlayer()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
    	Duel.BreakEffect()
        Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end