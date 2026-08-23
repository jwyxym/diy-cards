--饥饿的使徒
function c31280197.initial_effect(c)
	--特召或作为超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280197,3))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,31280197)
	e1:SetTarget(c31280197.target)
	e1:SetOperation(c31280197.operation)
	c:RegisterEffect(e1)
	--素材中效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280197,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetTarget(c31280197.target1)
	e2:SetOperation(c31280197.operation1)
	c:RegisterEffect(e2)
end
function c31280197.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c31280197.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3 
end
function c31280197.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=c:IsCanOverlay() and Duel.IsExistingTarget(c31280197.ovfilter,tp,LOCATION_MZONE,0,1,nil) 
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280197.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280197.filter,tp,LOCATION_MZONE,0,1,nil) 
    	and (b1 or b2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c31280197.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c31280197.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=c:IsCanOverlay() and tc:GetOverlayCount()>=3 
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(31280197,0)},{b2,aux.Stringid(31280197,1)})
    if op==1 then
    	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 
        	and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1200)
			tc:RegisterEffect(e1)
		end            
	elseif op==2 then     		        	
    	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) 
        	and c:IsCanOverlay() then
			local og=c:GetOverlayGroup()
			if og:GetCount()>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
			Duel.Overlay(tc,Group.FromCards(c))
		end            
	end
end
function c31280197.cfilter(c)
	return c:IsSetCard(0x5ca0) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c31280197.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280197.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c31280197.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c31280197.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end        
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	if Duel.GetTurnPlayer()==tp then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c31280197.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)      
end
function c31280197.skipcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end