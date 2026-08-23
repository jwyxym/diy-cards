--降诞的涸绝
function c31280216.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280216,0))
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,31280216)
	e1:SetTarget(c31280216.target)
	e1:SetOperation(c31280216.activate)
	e1:SetLabel(31280216)
	c:RegisterEffect(e1)
	--补充超量素材    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280216,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31380216)
	e2:SetCondition(c31280216.condition3)
	e2:SetTarget(c31280216.target3)
	e2:SetOperation(c31280216.operation3)
	c:RegisterEffect(e2)
end    
function c31280216.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return Duel.GetFlagEffect(tp,ct)==0 end
end
function c31280216.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c31280216.condition1)
	e1:SetOperation(c31280216.operation1)
    e1:SetCountLimit(1)
	Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c31280216.condition2)
	e2:SetOperation(c31280216.operation2)
    e2:SetCountLimit(1)
	Duel.RegisterEffect(e2,tp)	
	Duel.RegisterFlagEffect(tp,31280216,0,0,1)
end    
function c31280216.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end    
function c31280216.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=4 then
		Duel.Draw(tp,1,REASON_EFFECT)
    else    
    	Duel.Recover(tp,1200,REASON_EFFECT)
	end        
end
function c31280216.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end    
function c31280216.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)<=4 then
		Duel.Draw(1-tp,1,REASON_EFFECT)
    else    
    	Duel.Recover(1-tp,1200,REASON_EFFECT)
	end        
end
function c31280216.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function c31280216.condition3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(c31280216.cfilter,1,nil,tp)
end
function c31280216.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3 
end
function c31280216.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280216.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280216.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c31280216.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c31280216.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end