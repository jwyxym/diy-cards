--涸绝饥饿·吉鲁涅莉婕
function c31280198.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,2,2,c31280198.ovfilter,aux.Stringid(31280198,0),99,c31280198.xyzop)
    c:EnableReviveLimit()
	--不能作为超量素材    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--补充超量素材    
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DECKDES)
    e2:SetDescription(aux.Stringid(31280198,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c31280198.target)
	e2:SetOperation(c31280198.operation)
	c:RegisterEffect(e2)
	--升攻回复    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280198,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c31280198.condition1)
    e3:SetTarget(c31280198.target1)
	e3:SetOperation(c31280198.operation1)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(31280198,ACTIVITY_CHAIN,c31280198.chainfilter)
end
function c31280198.chainfilter(re,tp)
	return not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end
function c31280198.ovfilter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
function c31280198.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,31280198)==0
		and Duel.GetCustomActivityCount(31280198,1-tp,ACTIVITY_CHAIN)>0 end
	Duel.RegisterFlagEffect(tp,31280198,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c31280198.ovfilter1(c)
	return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) and c:IsCanOverlay()
end
function c31280198.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c31280198.ovfilter1(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(c31280198.ovfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,c31280198.ovfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,e:GetHandler())
end
function c31280198.tgfilter(c)
	return c:IsCode(31280215) and c:IsAbleToGrave()
end
function c31280198.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
        end    
        if Duel.Overlay(c,Group.FromCards(tc))~=0 and c:GetOverlayCount()>=10
        	and Duel.IsExistingMatchingCard(c31280198.tgfilter,tp,LOCATION_DECK,0,1,nil) 
            and Duel.SelectYesNo(tp,aux.Stringid(31280198,3)) then
            Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,c31280198.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
            	local tc=g:GetFirst()
                if tc:IsLocation(LOCATION_GRAVE) then    
                    Duel.BreakEffect()
					local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
					e:SetProperty(te:GetProperty())
					local tg=te:GetTarget()
					if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
            		local op=te:GetOperation()
					if op then op(e,tp,eg,ep,ev,re,r,rp) end
				end                    
			end                
		end
	end
end
function c31280198.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function c31280198.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
end
function c31280198.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()    
	if c:IsFaceup() and c:IsRelateToEffect(e) then   
     	local ovatk=c:GetOverlayCount()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ovatk*400)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
        if c:GetAttack()>0 then
        	Duel.BreakEffect()
        	Duel.Recover(tp,c:GetAttack(),REASON_EFFECT)
		end            
	end        
end