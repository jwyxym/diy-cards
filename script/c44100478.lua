--诺艾尔 黑玫瑰武装
function c44100478.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44100478.splimit)
	c:RegisterEffect(e1)
	--move pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100478,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,44100478)
	e2:SetCondition(c44100478.pccon)
	e2:SetTarget(c44100478.pctg)
	e2:SetOperation(c44100478.pcop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44100478,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,44110478)
	e3:SetCost(c44100478.thcost)
	e3:SetTarget(c44100478.thtg)
	e3:SetOperation(c44100478.thop)
	c:RegisterEffect(e3)
	--pendulem
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44100478,2))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,44110478)
	e4:SetCondition(c44100478.pencon)
	e4:SetCost(c44100478.pencost)
	e4:SetTarget(c44100478.pentg)
	e4:SetOperation(c44100478.penop)
	c:RegisterEffect(e4)
end
function c44100478.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x44a) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c44100478.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44a)
end
function c44100478.pccon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	return ct==0 or ct==Duel.GetMatchingGroupCount(c44100478.cfilter,tp,LOCATION_MZONE,0,nil)
end
function c44100478.pcfilter(c,tp)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsCode(44100478) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function c44100478.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() 
		and Duel.IsExistingMatchingCard(c44100478.pcfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c44100478.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,c44100478.pcfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
function c44100478.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c44100478.thfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c44100478.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c44100478.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c44100478.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c44100478.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c44100478.penfilter(c,tp)
	return c:IsSetCard(0x44a) and c:IsControler(tp)
end
function c44100478.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44100478.penfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function c44100478.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end
function c44100478.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c44100478.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
