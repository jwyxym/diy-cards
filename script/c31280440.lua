--魔兽支配者
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--超量召唤
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--补充超量素材    
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetCondition(s.ovcon)
	e1:SetOperation(s.ovop)
	c:RegisterEffect(e1)
	--攻击力下降    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.ovfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    local b1=c:GetFlagEffect(id)==0 and ep==tp
    local b2=c:GetFlagEffect(id+o)==0 and ep==1-tp
	return re:GetHandler()~=c and re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND+LOCATION_ONFIELD)~=0 and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.ovfilter,ep,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,e)
		and (b1 or b2)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() or not c:IsType(TYPE_XYZ) then return end
	Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(ep,s.ovfilter,ep,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,e):GetFirst()
	if tc then
		Duel.Hint(HINT_CARD,0,id)
        tc:CancelToGrave()
        Duel.HintSelection(Group.FromCards(tc))
		Duel.Overlay(c,tc)
        if ep==tp then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))	
        elseif ep==1-tp then
        	c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))	
        end    
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
    	local patk=c:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-800)
		c:RegisterEffect(e1)
        if patk~=0 and c:IsAttack(0) then
        	Duel.BreakEffect()
        	Duel.SendtoGrave(c,REASON_EFFECT)
        end
    end    
end