--饥饿绝杰·吉鲁涅莉婕
function c31280196.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,7,2,c31280196.ovfilter,aux.Stringid(31280196,0),99,c31280196.xyzop)
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
    e2:SetDescription(aux.Stringid(31280196,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31280196.condition)
	e2:SetTarget(c31280196.target)
	e2:SetOperation(c31280196.operation)
	c:RegisterEffect(e2)
	--不取对象    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetCondition(c31280196.condition1)
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(c31280196.value1)
	c:RegisterEffect(e4)
	--抽卡    
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31280196,2))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c31280196.condition2)
	e5:SetTarget(c31280196.target2)
	e5:SetOperation(c31280196.operation2)
	c:RegisterEffect(e5)    
    Duel.AddCustomActivityCounter(31280196,ACTIVITY_CHAIN,c31280196.chainfilter)
end
function c31280196.chainfilter(re,tp)
	return not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end
function c31280196.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c31280196.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,31280196)==0
		and Duel.GetCustomActivityCount(31280196,1-tp,ACTIVITY_CHAIN)>0 end
	Duel.RegisterFlagEffect(tp,31280196,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c31280196.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function c31280196.ovfilter1(c)
	return ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsType(TYPE_MONSTER)) and c:IsCanOverlay()
end
function c31280196.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c31280196.ovfilter1(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(c31280196.ovfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,c31280196.ovfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,e:GetHandler())
end
function c31280196.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function c31280196.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
        end    
        if Duel.Overlay(c,Group.FromCards(tc))~=0 then
      		local g=Duel.GetMatchingGroup(c31280196.atkfilter,tp,LOCATION_MZONE,0,nil,e)
            Duel.BreakEffect()    
			for gc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(800)
				gc:RegisterEffect(e1)				                    
            end    
		end  
	end
end
function c31280196.condition1(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end    
function c31280196.value1(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
function c31280196.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetOverlayCount()>=10
end
function c31280196.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5) end	
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
function c31280196.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,5,REASON_EFFECT)
	Duel.Draw(1-tp,5,REASON_EFFECT)
end